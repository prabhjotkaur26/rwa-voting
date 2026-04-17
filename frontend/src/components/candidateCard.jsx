export default function CandidateCard({ data, onSelect }) {
  return (
    <div
      onClick={onSelect}
      className="border rounded-xl p-4 shadow hover:shadow-lg cursor-pointer bg-white"
    >
      <img src={data.imageUrl} className="h-40 w-full object-cover rounded" />
      <h2 className="text-lg font-semibold mt-2">{data.name}</h2>
    </div>
  );
}
