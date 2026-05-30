import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { Pencil, Trash2 } from 'lucide-react';
import { toast } from 'react-toastify';
import PageHeader from '../components/PageHeader.jsx';
import EmptyState from '../components/EmptyState.jsx';
import { Field } from './Login.jsx';
import { categoryService } from '../services/categoryService';

export default function Categories() {
  const [categories, setCategories] = useState([]);
  const [editing, setEditing] = useState(null);
  const { register, handleSubmit, reset } = useForm({ defaultValues: { name: '', color: '#10b981' } });

  const load = () => categoryService.list().then(setCategories);
  useEffect(() => { load(); }, []);

  const onSubmit = async (values) => {
    try {
      editing ? await categoryService.update(editing.id, values) : await categoryService.create(values);
      toast.success(editing ? 'Category updated' : 'Category added');
      setEditing(null);
      reset({ name: '', color: '#10b981' });
      load();
    } catch (error) {
      toast.error(error.response?.data?.message || 'Unable to save category');
    }
  };

  const remove = async (id) => {
    await categoryService.remove(id);
    toast.success('Category deleted');
    load();
  };

  return (
    <>
      <PageHeader title="Categories" />
      <div className="grid gap-5 lg:grid-cols-[360px_1fr]">
        <form onSubmit={handleSubmit(onSubmit)} className="panel h-fit space-y-4 p-5">
          <h3 className="font-bold">{editing ? 'Edit Category' : 'Add Category'}</h3>
          <Field label="Name"><input className="input" {...register('name', { required: true })} /></Field>
          <Field label="Color"><input className="h-11 w-full rounded-lg border border-zinc-300 p-1 dark:border-zinc-700" type="color" {...register('color')} /></Field>
          <div className="flex gap-2">
            <button className="btn-primary">{editing ? 'Update' : 'Add'}</button>
            {editing ? <button type="button" className="btn-secondary" onClick={() => { setEditing(null); reset({ name: '', color: '#10b981' }); }}>Cancel</button> : null}
          </div>
        </form>
        <div className="panel p-5">
          {categories.length ? (
            <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
              {categories.map((category) => (
                <div key={category.id} className="flex items-center justify-between rounded-lg border border-zinc-200 p-3 dark:border-zinc-800">
                  <div className="flex items-center gap-3">
                    <span className="h-4 w-4 rounded-full" style={{ backgroundColor: category.color || '#10b981' }} />
                    <span className="font-semibold">{category.name}</span>
                  </div>
                  <div className="flex gap-2">
                    <button className="btn-secondary h-9 w-9 p-0" onClick={() => { setEditing(category); reset(category); }} aria-label="Edit category"><Pencil size={15} /></button>
                    <button className="btn-danger h-9 w-9 p-0" onClick={() => remove(category.id)} aria-label="Delete category"><Trash2 size={15} /></button>
                  </div>
                </div>
              ))}
            </div>
          ) : <EmptyState title="No categories" text="Add a category to organize transactions." />}
        </div>
      </div>
    </>
  );
}
