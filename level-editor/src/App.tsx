import { Toaster } from 'react-hot-toast';
import { useGridState } from './hooks/useGridState';
import { Grid } from './components/Grid';
import { Toolbar } from './components/Toolbar';
import { LayerToggle } from './components/LayerToggle';
import { ExportPanel } from './components/ExportPanel';
import { LevelSelector } from './components/LevelSelector';

function App() {
  const {
    levels,
    currentLevel,
    currentLevelIndex,
    layerMode,
    selectedTile,
    selectedMask,
    setLayerMode,
    setSelectedTile,
    setSelectedMask,
    updateCell,
    clearCell,
    addLevel,
    removeLevel,
    duplicateLevel,
    setCurrentLevelIndex,
  } = useGridState();

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-200 p-8">
      <Toaster position="top-right" />

      {/* Header */}
      <div className="max-w-7xl mx-auto mb-8">
        <h1 className="text-4xl font-bold text-gray-800 mb-2">
          🎮 Damaskus Level Editor
        </h1>
        <p className="text-gray-600">
          Create game levels with drag-and-drop. Export directly to GDScript.
        </p>
      </div>

      {/* Level Selector */}
      <div className="max-w-7xl mx-auto mb-6">
        <LevelSelector
          levels={levels}
          currentIndex={currentLevelIndex}
          onSelect={setCurrentLevelIndex}
          onAdd={addLevel}
          onRemove={removeLevel}
          onDuplicate={duplicateLevel}
        />
      </div>

      {/* Layer Toggle */}
      <div className="max-w-7xl mx-auto mb-6 flex justify-center">
        <LayerToggle layerMode={layerMode} onToggle={setLayerMode} />
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto flex gap-6">
        {/* Toolbar */}
        <Toolbar
          layerMode={layerMode}
          selectedTile={selectedTile}
          selectedMask={selectedMask}
          onTileSelect={setSelectedTile}
          onMaskSelect={setSelectedMask}
        />

        {/* Grid */}
        <div className="flex-1">
          <Grid
            level={currentLevel}
            layerMode={layerMode}
            onCellUpdate={updateCell}
            onCellClear={clearCell}
          />
        </div>

        {/* Export Panel */}
        <ExportPanel levels={levels} />
      </div>

      {/* Instructions */}
      <div className="max-w-7xl mx-auto mt-8 bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-bold mb-2">📖 Instructions</h3>
        <ul className="list-disc list-inside space-y-1 text-gray-700">
          <li><strong>Left-click</strong> to place selected tile/mask</li>
          <li><strong>Right-click</strong> to erase tile/mask</li>
          <li><strong>Click and drag</strong> to paint multiple cells</li>
          <li><strong>Toggle layers</strong> to edit level tiles or masks separately</li>
          <li><strong>Copy code</strong> from Export panel and paste into LevelGenerator.gd</li>
        </ul>
      </div>
    </div>
  );
}

export default App;
