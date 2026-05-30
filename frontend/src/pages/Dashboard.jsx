import { useEffect, useState } from 'react';
import { Area, AreaChart, Bar, BarChart, CartesianGrid, Cell, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import PageHeader from '../components/PageHeader.jsx';
import StatCard from '../components/StatCard.jsx';
import EmptyState from '../components/EmptyState.jsx';
import { reportService } from '../services/reportService';
import { transactionService } from '../services/transactionService';
import { formatCurrency, monthLabel } from '../utils/format';
import { useAuth } from '../context/AuthContext.jsx';

const COLORS = ['#10b981', '#f97316', '#0ea5e9', '#be123c', '#a855f7', '#14b8a6', '#64748b'];

export default function Dashboard() {
  const { user } = useAuth();
  const [summary, setSummary] = useState(null);
  const [monthly, setMonthly] = useState([]);
  const [categories, setCategories] = useState([]);
  const [recent, setRecent] = useState([]);
  const currency = user?.currency || 'USD';

  useEffect(() => {
    Promise.all([
      reportService.summary(),
      reportService.monthly(),
      reportService.categories(),
      transactionService.list({ page: 0, size: 5, sort: 'date,desc' }),
    ]).then(([s, m, c, t]) => {
      setSummary(s);
      setMonthly(m.map((row) => ({ ...row, label: monthLabel(row.month, row.year) })));
      setCategories(c);
      setRecent(t.content || []);
    });
  }, []);

  return (
    <>
      <PageHeader title="Dashboard" />
      <div className="grid gap-4 md:grid-cols-3">
        <StatCard title="Total Income" tone="mint" value={formatCurrency(summary?.totalIncome, currency)} />
        <StatCard title="Total Expense" tone="coral" value={formatCurrency(summary?.totalExpenses, currency)} />
        <StatCard title="Current Balance" tone="berry" value={formatCurrency(summary?.currentBalance, currency)} />
      </div>

      <div className="mt-6 grid gap-4 xl:grid-cols-3">
        <ChartPanel title="Monthly Spending" className="xl:col-span-2">
          {monthly.length ? (
            <ResponsiveContainer width="100%" height={280}>
              <AreaChart data={monthly}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="label" />
                <YAxis />
                <Tooltip />
                <Area dataKey="expense" stroke="#f97316" fill="#fed7aa" />
              </AreaChart>
            </ResponsiveContainer>
          ) : <EmptyState title="No spending yet" text="Add expenses to see trends." />}
        </ChartPanel>
        <ChartPanel title="Category Distribution">
          {categories.length ? (
            <ResponsiveContainer width="100%" height={280}>
              <PieChart>
                <Pie dataKey="amount" data={categories} nameKey="category" outerRadius={90}>
                  {categories.map((_, index) => <Cell key={index} fill={COLORS[index % COLORS.length]} />)}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          ) : <EmptyState title="No categories used" text="Expenses will appear here by category." />}
        </ChartPanel>
      </div>

      <div className="mt-6 grid gap-4 xl:grid-cols-[1fr_420px]">
        <ChartPanel title="Income vs Expense">
          <ResponsiveContainer width="100%" height={260}>
            <BarChart data={monthly}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="label" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="income" fill="#10b981" />
              <Bar dataKey="expense" fill="#f97316" />
            </BarChart>
          </ResponsiveContainer>
        </ChartPanel>
        <div className="panel p-5">
          <h3 className="mb-4 font-bold">Recent Transactions</h3>
          {recent.length ? (
            <div className="space-y-3">
              {recent.map((item) => (
                <div key={item.id} className="flex items-center justify-between border-b border-zinc-100 pb-3 last:border-0 dark:border-zinc-800">
                  <div>
                    <p className="font-semibold">{item.title}</p>
                    <p className="text-sm text-zinc-500">{item.category.name} · {item.date}</p>
                  </div>
                  <p className={item.type === 'INCOME' ? 'font-bold text-mint' : 'font-bold text-coral'}>{formatCurrency(item.amount, currency)}</p>
                </div>
              ))}
            </div>
          ) : <EmptyState title="No transactions" text="Create an income or expense to get started." />}
        </div>
      </div>
    </>
  );
}

function ChartPanel({ title, children, className = '' }) {
  return (
    <div className={`panel p-5 ${className}`}>
      <h3 className="mb-4 font-bold">{title}</h3>
      {children}
    </div>
  );
}
