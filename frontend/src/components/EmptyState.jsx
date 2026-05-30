export default function EmptyState({ title, text }) {
  return (
    <div className="grid min-h-40 place-items-center rounded-lg border border-dashed border-zinc-300 p-6 text-center dark:border-zinc-700">
      <div>
        <p className="font-semibold">{title}</p>
        <p className="mt-1 text-sm text-zinc-500">{text}</p>
      </div>
    </div>
  );
}
