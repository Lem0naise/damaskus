import { useState } from 'react';
import type { Level } from '../types/level';
import { Plus, Trash2, Copy, GripVertical, Edit2 } from 'lucide-react';
import clsx from 'clsx';
import {
  DndContext,
  closestCenter,
  PointerSensor,
  useSensor,
  useSensors,
  type DragEndEvent,
} from '@dnd-kit/core';
import {
  SortableContext,
  useSortable,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { RenameLevelModal } from './RenameLevelModal';

interface LevelSelectorProps {
  levels: Level[];
  currentIndex: number;
  onSelect: (index: number) => void;
  onAdd: () => void;
  onRemove: (index: number) => void;
  onDuplicate: (index: number) => void;
  onReorder: (startIndex: number, endIndex: number) => void;
  onRename: (index: number, newName: string) => void;
}

// Sortable Level Card Component
const SortableLevelCard = ({
  level,
  index,
  isSelected,
  onSelect,
  onDuplicate,
  onRemove,
  onRename,
  canRemove,
}: {
  level: Level;
  index: number;
  isSelected: boolean;
  onSelect: () => void;
  onDuplicate: () => void;
  onRemove: () => void;
  onRename: () => void;
  canRemove: boolean;
}) => {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: level.id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={clsx(
        'relative p-3 rounded-lg border-2 transition-all group flex items-center gap-2',
        isSelected
          ? 'border-blue-500 bg-blue-50'
          : 'border-gray-200 hover:border-gray-400'
      )}
    >
      {/* Drag Handle */}
      <div
        {...attributes}
        {...listeners}
        className="cursor-grab active:cursor-grabbing p-1 hover:bg-gray-200 rounded"
      >
        <GripVertical size={16} className="text-gray-400" />
      </div>

      {/* Level Info */}
      <div className="flex-1 cursor-pointer" onClick={onSelect}>
        <div className="font-semibold">{level.name}</div>
        <div className="text-xs text-gray-500">Level {index + 1}</div>
      </div>

      {/* Action Buttons */}
      <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
        <button
          onClick={(e) => {
            e.stopPropagation();
            onRename();
          }}
          className="p-1 bg-purple-500 text-white rounded hover:bg-purple-600"
          title="Rename"
        >
          <Edit2 size={12} />
        </button>
        <button
          onClick={(e) => {
            e.stopPropagation();
            onDuplicate();
          }}
          className="p-1 bg-blue-500 text-white rounded hover:bg-blue-600"
          title="Duplicate"
        >
          <Copy size={12} />
        </button>
        {canRemove && (
          <button
            onClick={(e) => {
              e.stopPropagation();
              onRemove();
            }}
            className="p-1 bg-red-500 text-white rounded hover:bg-red-600"
            title="Delete"
          >
            <Trash2 size={12} />
          </button>
        )}
      </div>
    </div>
  );
};

// Main Component
export const LevelSelector = ({
  levels,
  currentIndex,
  onSelect,
  onAdd,
  onRemove,
  onDuplicate,
  onReorder,
  onRename,
}: LevelSelectorProps) => {
  const [renamingIndex, setRenamingIndex] = useState<number | null>(null);
  const sensors = useSensors(useSensor(PointerSensor));

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (over && active.id !== over.id) {
      const oldIndex = levels.findIndex((l) => l.id === active.id);
      const newIndex = levels.findIndex((l) => l.id === over.id);
      onReorder(oldIndex, newIndex);
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-lg p-4">
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-xl font-bold">Levels</h2>
        <button
          onClick={onAdd}
          className="flex items-center gap-2 px-3 py-1 bg-green-500 text-white rounded hover:bg-green-600 transition"
        >
          <Plus size={16} />
          Add Level
        </button>
      </div>

      <DndContext
        sensors={sensors}
        collisionDetection={closestCenter}
        onDragEnd={handleDragEnd}
      >
        <SortableContext
          items={levels.map((l) => l.id)}
          strategy={verticalListSortingStrategy}
        >
          <div className="space-y-2">
            {levels.map((level, index) => (
              <SortableLevelCard
                key={level.id}
                level={level}
                index={index}
                isSelected={currentIndex === index}
                onSelect={() => onSelect(index)}
                onDuplicate={() => onDuplicate(index)}
                onRemove={() => onRemove(index)}
                onRename={() => setRenamingIndex(index)}
                canRemove={levels.length > 1}
              />
            ))}
          </div>
        </SortableContext>
      </DndContext>

      {/* Rename Modal */}
      {renamingIndex !== null && (
        <RenameLevelModal
          currentName={levels[renamingIndex].name}
          onRename={(newName) => {
            onRename(renamingIndex, newName);
            setRenamingIndex(null);
          }}
          onClose={() => setRenamingIndex(null)}
        />
      )}
    </div>
  );
};
