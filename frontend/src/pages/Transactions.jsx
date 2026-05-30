import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { Download, Pencil, Plus, Trash2 } from 'lucide-react';
import { toast } from 'react-toastify';
import * as XLSX from 'xlsx';
import { saveAs } from 'file-saver';
import PageHeader from '../components/PageHeader.jsx';
import EmptyState from '../components/EmptyState.jsx';
import { Field } from './Login.jsx';
import { categoryService } from '../services/categoryService';
import { transactionService } from '../services/transactionService';
import { formatCurrency } from '../utils/format';
import { useAuth } from '../context/AuthContext.jsx';

const emptyForm = { title: '', description: '', amount: '', date: new Date().toISOString().slice(0, 10), type: 'EXPENSE', categoryId: '' };

export default function Transactions() {
  const { user } = useAuth();
  const [items, setItems] = useState([]);
  const [categories, setCategories] = useState([]);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(1);
  const [filters, setFilters] = useState({ search: '', categoryId: '', month: '' });
  const [editing, setEditing] = useState(null);
  const { register, handleSubmit, reset, formState: { isSubmitting } } = useForm({ defaultValues: emptyForm });
  const currency = user?.currency || 'USD';

  const load = async (nextPage = page) => {
    const params = {
      page: nextPage,
      size: 8,
      sort: 'date,desc',
      search: filters.search || undefined,
      categoryId: filters.categoryId || undefined,
      month: filters.month || undefined,
    };
    const data = await transactionService.list(params);
    setItems(data.content || []);
    setTotalPages(data.totalPages || 1);
    setPage(nextPage);
  };

  useEffect(() => {
    categoryService.list().then(setCategories);
  }, []);

  useEffect(() => {
    load(0);
  }, [filters]);

  const onSubmit = async (values) => {
    const payload = { ...values, amount: Number(values.amount) };
    try {
      if (editing) {
        await transactionService.update(editing.id, payload);
        toast.success('Transaction updated');
      } else {
        await transactionService.create(payload);
        toast.success('Transaction added');
      }
      setEditing(null);
      reset(emptyForm);
      load(0);
    } catch (error) {
      toast.error(error.response?.data?.message || 'Unable to save transaction');
    }
  };

  const edit = (item) => {
    setEditing(item);
    reset({ ...item, categoryId: item.category.id });
  };

  const remove = async (id) => {
    await transactionService.remove(id);
    toast.success('Transaction deleted');
    load();
  };

  const exportExcel = () => {
    const rows = items.map((item) => ({
      Date: item.date,
      Title: item.title,
      Category: item.category.name,
      Type: item.type,
      Amount: item.amount,
    }));
    const worksheet = XLSX.utils.json_to_sheet(rows);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Transactions');
    const output = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });
    saveAs(new Blob([output]), 'transactions.xlsx');
  };

  return (
    <>
      <PageHeader
        title="Transactions"
        actions={<button className="btn-secondary" onClick={exportExcel}><Download size={16} /> Export Excel</button>}
      />
      <div className="grid gap-5 xl:grid-cols-[380px_1fr]">
        <form onSubmit={handleSubmit(onSubmit)} className="panel h-fit space-y-4 p-5">
          <h3 className="font-bold">{editing ? 'Edit Transaction' : 'Add Transaction'}</h3>
          <Field label="Title"><input className="input" {...register('title', { required: true })} /></Field>
          <Field label="Description"><textarea className="input min-h-20" {...register('description')} /></Field>
          <div className="grid grid-cols-2 gap-3">
            <Field label="Amount"><input className="input" type="number" step="0.01" {...register('amount', { required: true })} /></Field>
            <Field label="Date"><input className="input" type="date" {...register('date', { required: true })} /></Field>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Field label="Type">
              <select className="input" {...register('type')}>
                <option value="EXPENSE">Expense</option>
                <option value="INCOME">Income</option>
              </select>
            </Field>
            <Field label="Category">
              <select className="input" {...register('categoryId', { required: true })}>
                <option value="">Select</option>
                {categories.map((category) => <option key={category.id} value={category.id}>{category.name}</option>)}
              </select>
            </Field>
          </div>
          <div className="flex gap-2">
            <button className="btn-primary" disabled={isSubmitting}><Plus size={16} /> {editing ? 'Update' : 'Add'}</button>
            {editing ? <button type="button" className="btn-secondary" onClick={() => { setEditing(null); reset(emptyForm); }}>Cancel</button> : null}
          </div>
        </form>

        <div className="panel p-5">
          <div className="mb-4 grid gap-3 md:grid-cols-3">
            <input className="input" placeholder="Search" value={filters.search} onChange={(e) => setFilters({ ...filters, search: e.target.value })} />
            <select className="input" value={filters.categoryId} onChange={(e) => setFilters({ ...filters, categoryId: e.target.value })}>
              <option value="">All categories</option>
              {categories.map((category) => <option key={category.id} value={category.id}>{category.name}</option>)}
            </select>
            <input className="input" type="month" value={filters.month} onChange={(e) => setFilters({ ...filters, month: e.target.value })} />
          </div>
          {items.length ? (
            <>
              <div className="overflow-x-auto">
                <table className="w-full min-w-[720px] text-left text-sm">
                  <thead className="text-xs uppercase text-zinc-500">
                    <tr><th className="py-3">Date</th><th>Title</th><th>Category</th><th>Type</th><th>Amount</th><th>Actions</th></tr>
                  </thead>
                  <tbody>
                    {items.map((item) => (
                      <tr key={item.id} className="border-t border-zinc-100 dark:border-zinc-800">
                        <td className="py-3">{item.date}</td>
                        <td className="font-semibold">{item.title}</td>
                        <td>{item.category.name}</td>
                        <td>{item.type}</td>
                        <td className={item.type === 'INCOME' ? 'font-bold text-mint' : 'font-bold text-coral'}>{formatCurrency(item.amount, currency)}</td>
                        <td className="flex gap-2 py-2">
                          <button className="btn-secondary h-9 w-9 p-0" onClick={() => edit(item)} aria-label="Edit transaction"><Pencil size={15} /></button>
                          <button className="btn-danger h-9 w-9 p-0" onClick={() => remove(item.id)} aria-label="Delete transaction"><Trash2 size={15} /></button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <div className="mt-4 flex items-center justify-between">
                <button className="btn-secondary" disabled={page === 0} onClick={() => load(page - 1)}>Previous</button>
                <span className="text-sm text-zinc-500">Page {page + 1} of {totalPages}</span>
                <button className="btn-secondary" disabled={page + 1 >= totalPages} onClick={() => load(page + 1)}>Next</button>
              </div>
            </>
          ) : <EmptyState title="No transactions found" text="Adjust filters or add a new transaction." />}
        </div>
      </div>
    </>
  );
}
