import { useForm } from 'react-hook-form';
import { toast } from 'react-toastify';
import PageHeader from '../components/PageHeader.jsx';
import { Field } from './Login.jsx';
import { useAuth } from '../context/AuthContext.jsx';
import { authService } from '../services/authService';

const currencies = ['USD', 'EUR', 'GBP', 'LKR', 'INR', 'AUD', 'CAD', 'JPY'];

export default function Profile() {
  const { user, setUser } = useAuth();
  const { register, handleSubmit, formState: { isSubmitting } } = useForm({ defaultValues: user });

  const onSubmit = async (values) => {
    try {
      const updated = await authService.updateProfile(values);
      setUser(updated);
      toast.success('Profile updated');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Unable to update profile');
    }
  };

  return (
    <>
      <PageHeader title="Profile" />
      <form onSubmit={handleSubmit(onSubmit)} className="panel max-w-2xl space-y-4 p-5">
        <Field label="Name"><input className="input" {...register('name', { required: true })} /></Field>
        <Field label="Profile Picture URL"><input className="input" {...register('profilePictureUrl')} /></Field>
        <Field label="Currency">
          <select className="input" {...register('currency', { required: true })}>
            {currencies.map((currency) => <option key={currency} value={currency}>{currency}</option>)}
          </select>
        </Field>
        <button className="btn-primary" disabled={isSubmitting}>Save Profile</button>
      </form>
    </>
  );
}
