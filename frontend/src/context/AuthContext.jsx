import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { toast } from 'react-toastify';
import { authService } from '../services/authService';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(Boolean(localStorage.getItem('expense_tracker_token')));

  useEffect(() => {
    const token = localStorage.getItem('expense_tracker_token');
    if (!token) return;
    authService
      .me()
      .then(setUser)
      .catch(() => localStorage.removeItem('expense_tracker_token'))
      .finally(() => setLoading(false));
  }, []);

  const login = async (payload) => {
    const data = await authService.login(payload);
    localStorage.setItem('expense_tracker_token', data.token);
    setUser(data.user);
    toast.success('Welcome back');
    return data;
  };

  const register = async (payload) => {
    const data = await authService.register(payload);
    localStorage.setItem('expense_tracker_token', data.token);
    setUser(data.user);
    toast.success('Account created');
    return data;
  };

  const logout = () => {
    localStorage.removeItem('expense_tracker_token');
    setUser(null);
  };

  const value = useMemo(() => ({ user, setUser, loading, login, register, logout }), [user, loading]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export const useAuth = () => useContext(AuthContext);
