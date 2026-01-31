import { useState } from 'react';
import type { Level } from '../types/level';
import { exportToGDScript, exportToJSON } from '../utils/exporter';
import { Copy, Download, Check } from 'lucide-react';
import toast from 'react-hot-toast';

interface ExportPanelProps {
  levels: Level[];
}

export const ExportPanel = ({ levels }: ExportPanelProps) => {
  const [copied, setCopied] = useState(false);
  const gdscriptCode = exportToGDScript(levels);
  const jsonData = exportToJSON(levels);

  const handleCopy = async () => {
    await navigator.clipboard.writeText(gdscriptCode);
    setCopied(true);
    toast.success('Copied to clipboard!');
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownloadJSON = () => {
    const blob = new Blob([jsonData], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'levels.json';
    a.click();
    URL.revokeObjectURL(url);
    toast.success('Downloaded levels.json');
  };

  return (
    <div className="w-96 bg-white rounded-lg shadow-lg p-4">
      <h2 className="text-xl font-bold mb-4">Export</h2>

      <div className="space-y-4">
        {/* GDScript Export */}
        <div>
          <div className="flex items-center justify-between mb-2">
            <h3 className="font-semibold">GDScript Arrays</h3>
            <button
              onClick={handleCopy}
              className="flex items-center gap-2 px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600 transition"
            >
              {copied ? <Check size={16} /> : <Copy size={16} />}
              {copied ? 'Copied!' : 'Copy'}
            </button>
          </div>
          <pre className="bg-gray-100 p-3 rounded text-xs overflow-auto max-h-96 border">
            <code>{gdscriptCode}</code>
          </pre>
        </div>

        {/* JSON Export */}
        <div>
          <div className="flex items-center justify-between mb-2">
            <h3 className="font-semibold">JSON (Save/Load)</h3>
            <button
              onClick={handleDownloadJSON}
              className="flex items-center gap-2 px-3 py-1 bg-green-500 text-white rounded hover:bg-green-600 transition"
            >
              <Download size={16} />
              Download
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
