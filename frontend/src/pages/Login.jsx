import { Link, useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { toast } from 'react-toastify';
import { useAuth } from '../context/AuthContext.jsx';

export default function Login() {
  const navigate = useNavigate();
  const { login } = useAuth();
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm();

  const onSubmit = async (values) => {
    try {
      await login(values);
      navigate('/');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Login failed');
    }
  };

  return (
    <AuthFrame title="Welcome back" subtitle="Track your money with a clear, secure dashboard.">
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <Field label="Email" error={errors.email?.message}>
          <input className="input" type="email" {...register('email', { required: 'Email is required' })} />
        </Field>
        <Field label="Password" error={errors.password?.message}>
          <input className="input" type="password" {...register('password', { required: 'Password is required' })} />
        </Field>
        <button className="btn-primary w-full" disabled={isSubmitting}>Sign in</button>
      </form>
      <p className="mt-5 text-center text-sm text-zinc-500">
        New here? <Link className="font-semibold text-mint" to="/register">Create an account</Link>
      </p>
    </AuthFrame>
  );
}

export function AuthFrame({ title, subtitle, children }) {
  return (
    <div className="grid min-h-screen place-items-center bg-zinc-100 px-4 dark:bg-zinc-950">
      <div className="w-full max-w-md panel p-6">
        <p className="text-sm font-semibold uppercase text-mint">Expense Tracker</p>
        <h1 className="mt-2 text-3xl font-bold">{title}</h1>
        <p className="mb-6 mt-2 text-sm text-zinc-500">{subtitle}</p>
        {children}
      </div>
    </div>
  );
}

export function Field({ label, error, children }) {
  return (
    <label className="block">
      <span className="mb-1 block text-sm font-medium">{label}</span>
      {children}
      {error ? <span className="mt-1 block text-xs text-berry">{error}</span> : null}
    </label>
  );
}
