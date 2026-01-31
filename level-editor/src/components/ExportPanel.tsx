import { useState } from 'react';
import type { Level } from '../types/level';
import { exportToGDScript, exportToJSON, parseGDScriptLevels } from '../utils/exporter';
import { Copy, Download, Check, Upload, FileUp } from 'lucide-react';
import toast from 'react-hot-toast';

interface ExportPanelProps {
  levels: Level[];
  onLoadLevels: (levels: Level[]) => void;
}

export const ExportPanel = ({ levels, onLoadLevels }: ExportPanelProps) => {
  const [copied, setCopied] = useState(false);
  const [importText, setImportText] = useState('');
  const [showImport, setShowImport] = useState(false);

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

  const handleImportGDScript = () => {
    try {
      const parsedLevels = parseGDScriptLevels(importText);
      onLoadLevels(parsedLevels);
      toast.success(`Loaded ${parsedLevels.length} levels!`);
      setImportText('');
      setShowImport(false);
    } catch (error) {
      toast.error(`Import failed: ${error}`);
    }
  };

  const handleImportJSON = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const content = e.target?.result as string;
        const parsedLevels = JSON.parse(content) as Level[];
        onLoadLevels(parsedLevels);
        toast.success(`Loaded ${parsedLevels.length} levels from JSON!`);
      } catch (error) {
        toast.error(`Failed to load JSON: ${error}`);
      }
    };
    reader.readAsText(file);
  };

  return (
    <div className="w-96 bg-white rounded-lg shadow-lg p-4">
      <h2 className="text-xl font-bold mb-4">Export / Import</h2>

      <div className="space-y-4">
        {/* Import Section */}
        <div className="border-b pb-4">
          <div className="flex items-center justify-between mb-2">
            <h3 className="font-semibold">Import Levels</h3>
            <button
              onClick={() => setShowImport(!showImport)}
              className="flex items-center gap-2 px-3 py-1 bg-purple-500 text-white rounded hover:bg-purple-600 transition"
            >
              <Upload size={16} />
              {showImport ? 'Hide' : 'Show'}
            </button>
          </div>

          {showImport && (
            <div className="space-y-2">
              <div>
                <label className="text-sm font-medium text-gray-700 block mb-1">
                  Paste GDScript Code
                </label>
                <textarea
                  value={importText}
                  onChange={(e) => setImportText(e.target.value)}
                  placeholder="Paste var level_layouts = [...] and var level_masks = [...] here"
                  className="w-full h-32 p-2 border rounded text-xs font-mono"
                />
                <button
                  onClick={handleImportGDScript}
                  disabled={!importText.trim()}
                  className="mt-2 w-full flex items-center justify-center gap-2 px-3 py-2 bg-green-500 text-white rounded hover:bg-green-600 transition disabled:bg-gray-300 disabled:cursor-not-allowed"
                >
                  <FileUp size={16} />
                  Load All Levels
                </button>
              </div>

              <div className="text-center text-sm text-gray-500">or</div>

              <div>
                <label className="text-sm font-medium text-gray-700 block mb-1">
                  Import JSON File
                </label>
                <input
                  type="file"
                  accept=".json"
                  onChange={handleImportJSON}
                  className="w-full text-sm"
                />
              </div>
            </div>
          )}
        </div>

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
