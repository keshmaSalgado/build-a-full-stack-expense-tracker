export default function StatCard({ title, value, tone = 'mint' }) {
  const tones = {
    mint: 'border-l-mint',
    coral: 'border-l-coral',
    berry: 'border-l-berry',
  };

  return (
    <div className={`panel border-l-4 ${tones[tone]} p-5`}>
      <p className="text-sm font-medium text-zinc-500">{title}</p>
      <p className="mt-2 text-2xl font-bold">{value}</p>
    </div>
  );
}
