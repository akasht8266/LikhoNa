import 'react-native-url-polyfill/auto';
import * as SecureStore from 'expo-secure-store';
import { createClient, processLock, SupportedStorage } from '@supabase/supabase-js';

const SecureStorage: SupportedStorage = {
  getItem: (key) => SecureStore.getItemAsync(key),
  setItem: (key, value) => SecureStore.setItemAsync(key, value),
  removeItem: (key) => SecureStore.deleteItemAsync(key),
};
const url = process.env.EXPO_PUBLIC_SUPABASE_URL;
const key = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY;
export const backendConfigured = Boolean(url && key && !url.includes('YOUR_PROJECT_ID') && !key.includes('YOUR_SUPABASE'));
export const supabase = createClient(url || 'https://example.supabase.co', key || 'not-configured', {
  auth: { storage: SecureStorage, autoRefreshToken: true, persistSession: true, detectSessionInUrl: false, lock: processLock },
});
