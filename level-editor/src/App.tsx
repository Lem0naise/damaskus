import { useState } from 'react';
import { Toaster } from 'react-hot-toast';
import { useGridState } from './hooks/useGridState';
import { Grid } from './components/Grid';
import { Toolbar } from './components/Toolbar';
import { LayerToggle } from './components/LayerToggle';
import { ExportPanel } from './components/ExportPanel';
import { PublishPanel } from './components/PublishPanel';
import { LevelSelector } from './components/LevelSelector';
import { SelectedItemTooltip } from './components/SelectedItemTooltip';
import { ChevronDown, ChevronUp } from 'lucide-react';

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
    reorderLevels,
    renameLevel,
    setCurrentLevelIndex,
    loadLevels,
  } = useGridState();

  const [showDeveloperTools, setShowDeveloperTools] = useState(false);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-200 p-2 sm:p-4 md:p-8">
      <Toaster position="top-right" />

      {/* Header */}
      <div className="max-w-7xl mx-auto mb-4 md:mb-8">
        <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-800 mb-1 md:mb-2">
          Damaskus Level Editor
        </h1>
        <p className="text-sm sm:text-base text-gray-600">
          Create game levels and publish them to the community!!
        </p>
      </div>

      {/* Layer Toggle */}
      <div className="max-w-7xl mx-auto mb-4 md:mb-6 flex justify-center">
        <LayerToggle layerMode={layerMode} onToggle={setLayerMode} />
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto flex flex-col lg:flex-row gap-4 md:gap-6">
        {/* Toolbar */}
        <Toolbar
          layerMode={layerMode}
          selectedTile={selectedTile}
          selectedMask={selectedMask}
          onTileSelect={setSelectedTile}
          onMaskSelect={setSelectedMask}
        />

        {/* Grid */}
        <div className="flex-1 flex flex-col gap-4 order-first lg:order-none">
          <Grid
            level={currentLevel}
            layerMode={layerMode}
            onCellUpdate={updateCell}
            onCellClear={clearCell}
          />

          {/* Selected Item Tooltip */}
          <SelectedItemTooltip
            layerMode={layerMode}
            selectedTile={selectedTile}
            selectedMask={selectedMask}
          />
        </div>

        {/* Right Sidebar - Publish Panel - Hidden on narrow screens */}
        <div className="hidden xl:flex flex-col gap-4 md:gap-6">
          <PublishPanel currentLevel={currentLevel} />
        </div>
      </div>

      {/* Mobile Publish Panel - Shows only on narrow screens */}
      <div className="max-w-7xl mx-auto mt-4 md:mt-6 xl:hidden">
        <PublishPanel currentLevel={currentLevel} />
      </div>

      {/* Instructions */}
      <div className="max-w-7xl mx-auto mt-4 md:mt-8 bg-white rounded-lg shadow p-4 md:p-6">
        <h3 className="text-base md:text-lg font-bold mb-2">Instructions</h3>
        <ul className="list-disc list-inside space-y-1 text-sm md:text-base text-gray-700">
          <li><strong>Left-click</strong> to place selected tile/mask</li>
          <li><strong>Right-click</strong> to erase tile/mask</li>
          <li><strong>Click and drag</strong> to paint multiple cells</li>
          <li><strong>Toggle layers</strong> to edit level tiles or masks separately</li>
          <li><strong>Required</strong>: Each level needs one Player Spawn (-1) and at least one GOAL mask (3)</li>
        </ul>

        <div className="mt-4 p-3 bg-blue-50 rounded border border-blue-200">
          <h4 className="text-sm md:text-base font-semibold text-blue-900 mb-1">Columns</h4>
          <p className="text-xs md:text-sm text-blue-800">
            Red columns start DOWN (raised in blue mode). Blue columns start UP (lowered in blue mode).
            Get GOLEM mask to control them - press Space to toggle between modes.
          </p>
        </div>
      </div>

      {/* Developer Tools Section */}
      <div className="max-w-7xl mx-auto mt-4 md:mt-6 bg-white rounded-lg shadow">
        <button
          onClick={() => setShowDeveloperTools(!showDeveloperTools)}
          className="w-full px-6 py-4 flex items-center justify-between hover:bg-gray-50 transition rounded-lg"
        >
          <div className="flex items-center gap-2">
            <span className="text-sm font-mono text-gray-500">{'</>'}</span>
            <span className="font-semibold text-gray-700">For Developers</span>
          </div>
          {showDeveloperTools ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
        </button>

        {showDeveloperTools && (
          <div className="px-6 pb-6 space-y-6 border-t">
            {/* Level Selector */}
            <div className="pt-6">
              <h3 className="font-semibold text-gray-700 mb-3">Multiple Levels Mode</h3>
              <LevelSelector
                levels={levels}
                currentIndex={currentLevelIndex}
                onSelect={setCurrentLevelIndex}
                onAdd={addLevel}
                onRemove={removeLevel}
                onDuplicate={duplicateLevel}
                onReorder={reorderLevels}
                onRename={renameLevel}
              />
            </div>

            {/* Export/Import Panel */}
            <div>
              <h3 className="font-semibold text-gray-700 mb-3">Export/Import Tools</h3>
              <ExportPanel levels={levels} onLoadLevels={loadLevels} />
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
