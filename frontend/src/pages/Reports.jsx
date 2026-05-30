import { useEffect, useState } from 'react';
import jsPDF from 'jspdf';
import { Download } from 'lucide-react';
import { Bar, BarChart, CartesianGrid, Cell, Line, LineChart, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import PageHeader from '../components/PageHeader.jsx';
import EmptyState from '../components/EmptyState.jsx';
import { reportService } from '../services/reportService';
import { monthLabel } from '../utils/format';

const COLORS = ['#10b981', '#f97316', '#0ea5e9', '#be123c', '#a855f7', '#14b8a6', '#64748b'];

export default function Reports() {
  const [monthly, setMonthly] = useState([]);
  const [categories, setCategories] = useState([]);
  const [summary, setSummary] = useState(null);

  useEffect(() => {
    Promise.all([reportService.monthly(), reportService.categories(), reportService.summary()]).then(([m, c, s]) => {
      setMonthly(m.map((row) => ({ ...row, label: monthLabel(row.month, row.year) })));
      setCategories(c);
      setSummary(s);
    });
  }, []);

  const exportPdf = () => {
    const doc = new jsPDF();
    doc.text('Expense Tracker Report', 16, 18);
    doc.text(`Total income: ${summary?.totalIncome || 0}`, 16, 32);
    doc.text(`Total expenses: ${summary?.totalExpenses || 0}`, 16, 42);
    doc.text(`Current balance: ${summary?.currentBalance || 0}`, 16, 52);
    doc.save('expense-report.pdf');
  };

  return (
    <>
      <PageHeader title="Reports" actions={<button className="btn-secondary" onClick={exportPdf}><Download size={16} /> Export PDF</button>} />
      <div className="grid gap-5 xl:grid-cols-2">
        <Panel title="Monthly Expense Trends">
          {monthly.length ? (
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={monthly}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="label" />
                <YAxis />
                <Tooltip />
                <Line type="monotone" dataKey="expense" stroke="#f97316" strokeWidth={3} />
              </LineChart>
            </ResponsiveContainer>
          ) : <EmptyState title="No expense data" text="Reports update after transactions are recorded." />}
        </Panel>

        <Panel title="Monthly Income Trends">
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={monthly}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="label" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="income" stroke="#10b981" strokeWidth={3} />
            </LineChart>
          </ResponsiveContainer>
        </Panel>

        <Panel title="Spending by Category">
          {categories.length ? (
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie data={categories} dataKey="amount" nameKey="category" outerRadius={100} label>
                  {categories.map((_, index) => <Cell key={index} fill={COLORS[index % COLORS.length]} />)}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          ) : <EmptyState title="No category spending" text="Expense categories appear here automatically." />}
        </Panel>

        <Panel title="Income vs Expense Comparison">
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={monthly}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="label" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="income" fill="#10b981" />
              <Bar dataKey="expense" fill="#f97316" />
            </BarChart>
          </ResponsiveContainer>
        </Panel>
      </div>
    </>
  );
}

function Panel({ title, children }) {
  return (
    <div className="panel p-5">
      <h3 className="mb-4 font-bold">{title}</h3>
      {children}
    </div>
  );
}
