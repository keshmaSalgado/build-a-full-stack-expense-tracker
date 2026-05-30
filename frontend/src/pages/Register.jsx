import { Link, useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { toast } from 'react-toastify';
import { useAuth } from '../context/AuthContext.jsx';
import { AuthFrame, Field } from './Login.jsx';

export default function Register() {
  const navigate = useNavigate();
  const { register: createAccount } = useAuth();
  const { register, handleSubmit, watch, formState: { errors, isSubmitting } } = useForm();
  const password = watch('password');

  const onSubmit = async (values) => {
    try {
      await createAccount(values);
      navigate('/');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Registration failed');
    }
  };

  return (
    <AuthFrame title="Create account" subtitle="Start with default categories and personalize from there.">
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <Field label="Name" error={errors.name?.message}>
          <input className="input" {...register('name', { required: 'Name is required' })} />
        </Field>
        <Field label="Email" error={errors.email?.message}>
          <input className="input" type="email" {...register('email', { required: 'Email is required' })} />
        </Field>
        <Field label="Password" error={errors.password?.message}>
          <input className="input" type="password" {...register('password', { required: 'Password is required', minLength: { value: 8, message: 'Use at least 8 characters' } })} />
        </Field>
        <Field label="Confirm Password" error={errors.confirmPassword?.message}>
          <input className="input" type="password" {...register('confirmPassword', { validate: (value) => value === password || 'Passwords must match' })} />
        </Field>
        <button className="btn-primary w-full" disabled={isSubmitting}>Create account</button>
      </form>
      <p className="mt-5 text-center text-sm text-zinc-500">
        Already registered? <Link className="font-semibold text-mint" to="/login">Sign in</Link>
      </p>
    </AuthFrame>
  );
}
