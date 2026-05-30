import { NavLink, Outlet } from 'react-router-dom';
import { BarChart3, CreditCard, FolderOpen, LayoutDashboard, LogOut, Moon, Sun, UserRound } from 'lucide-react';
import { useAuth } from '../context/AuthContext.jsx';
import { useTheme } from '../context/ThemeContext.jsx';

const navItems = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard },
  { to: '/transactions', label: 'Transactions', icon: CreditCard },
  { to: '/categories', label: 'Categories', icon: FolderOpen },
  { to: '/reports', label: 'Reports', icon: BarChart3 },
  { to: '/profile', label: 'Profile', icon: UserRound },
];

export default function AppLayout() {
  const { user, logout } = useAuth();
  const { dark, setDark } = useTheme();

  return (
    <div className="min-h-screen lg:grid lg:grid-cols-[260px_1fr]">
      <aside className="border-r border-zinc-200 bg-white px-4 py-5 dark:border-zinc-800 dark:bg-zinc-900">
        <div className="mb-6 flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold uppercase text-mint">Finance</p>
            <h1 className="text-xl font-bold">Expense Tracker</h1>
          </div>
          <button className="btn-secondary h-10 w-10 p-0 lg:hidden" onClick={() => setDark(!dark)} aria-label="Toggle theme">
            {dark ? <Sun size={18} /> : <Moon size={18} />}
          </button>
        </div>
        <nav className="grid grid-cols-2 gap-2 lg:grid-cols-1">
          {navItems.map((item) => {
            const Icon = item.icon;
            return (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.to === '/'}
                className={({ isActive }) =>
                  `flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-semibold ${
                    isActive ? 'bg-mint text-white' : 'text-zinc-600 hover:bg-zinc-100 dark:text-zinc-300 dark:hover:bg-zinc-800'
                  }`
                }
              >
                <Icon size={18} />
                {item.label}
              </NavLink>
            );
          })}
        </nav>
      </aside>

      <main className="min-w-0">
        <header className="sticky top-0 z-10 flex items-center justify-between border-b border-zinc-200 bg-zinc-100/90 px-4 py-3 backdrop-blur dark:border-zinc-800 dark:bg-zinc-950/90 sm:px-6">
          <div>
            <p className="text-sm text-zinc-500">Signed in as</p>
            <p className="font-semibold">{user?.name}</p>
          </div>
          <div className="flex items-center gap-2">
            <button className="btn-secondary h-10 w-10 p-0" onClick={() => setDark(!dark)} aria-label="Toggle theme">
              {dark ? <Sun size={18} /> : <Moon size={18} />}
            </button>
            <button className="btn-secondary h-10 w-10 p-0" onClick={logout} aria-label="Log out">
              <LogOut size={18} />
            </button>
          </div>
        </header>
        <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
