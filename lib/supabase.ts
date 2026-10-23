import 'react-native-url-polyfill/auto';
import * as SecureStore from 'expo-secure-store';
import { createClient, processLock, SupportedStorage } from '@supabase/supabase-js';

const SecureStorage: SupportedStorage = {
  getItem: (key) => SecureStore.getItemAsync(key),
  setItem: (key, value) => SecureStore.setItemAsync(key, value),
  removeItem: (key) => SecureStore.deleteItemAsync(key),
};

// Prefer Expo's build-time environment variables. The public Supabase client
// configuration is also provided as a fallback because EAS cloud builds may
// not receive a developer's ignored local .env file. Never use service_role here.
const SUPABASE_URL_FALLBACK = 'https://ttyrnfdqlvdqljkdfreh.supabase.co';
const SUPABASE_PUBLISHABLE_KEY_FALLBACK = 'sb_publishable_lQ_2WXSTk0TqW_qYm1gCPA_EZcniR5q';

const url = process.env.EXPO_PUBLIC_SUPABASE_URL || SUPABASE_URL_FALLBACK;
const key = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY || SUPABASE_PUBLISHABLE_KEY_FALLBACK;

export const backendConfigured = Boolean(
  url.startsWith('https://') &&
  url.includes('.supabase.co') &&
  key &&
  !url.includes('YOUR_PROJECT_ID') &&
  !key.includes('YOUR_SUPABASE') &&
  key !== 'not-configured'
);

export const supabase = createClient(url, key, {
  auth: {
    storage: SecureStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
    lock: processLock,
  },
});
