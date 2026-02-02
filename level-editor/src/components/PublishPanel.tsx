import { useState } from 'react';
import type { Level } from '../types/level';
import { validateLevel } from '../utils/validator';
import { publishLevel } from '../utils/api';
import { Upload, AlertCircle } from 'lucide-react';
import toast from 'react-hot-toast';

interface PublishPanelProps {
  currentLevel: Level;
}

export const PublishPanel = ({ currentLevel }: PublishPanelProps) => {
  const [levelName, setLevelName] = useState('');
  const [authorName, setAuthorName] = useState('');
  const [description, setDescription] = useState('');
  const [difficulty, setDifficulty] = useState('Medium');
  const [isPublishing, setIsPublishing] = useState(false);

  const handlePublish = async () => {
    // Validate level
    const errors = validateLevel(currentLevel);
    if (errors.length > 0) {
      toast.error(`Validation failed: ${errors[0]}`);
      return;
    }

    // Validate metadata
    if (!levelName.trim() || levelName.length < 3) {
      toast.error('Level name must be at least 3 characters');
      return;
    }

    if (!authorName.trim() || authorName.length < 3) {
      toast.error('Author name must be at least 3 characters');
      return;
    }

    setIsPublishing(true);

    try {
      const response = await publishLevel({
        level: {
          ...currentLevel,
          name: levelName.trim()
        },
        metadata: {
          authorName: authorName.trim(),
          description: description.trim(),
          difficulty,
          tags: [] // Empty array, no tags
        }
      });

      toast.success('🎉 Level published successfully!');
      console.log('Level ID:', response.levelId);

      // Reset form
      setLevelName('');
      setDescription('');
    } catch (error: any) {
      toast.error(`Publish failed: ${error.message}`);
    } finally {
      setIsPublishing(false);
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-lg p-4 md:p-6 w-full max-w-md">
      <h2 className="text-xl md:text-2xl font-bold mb-3 md:mb-4 flex items-center gap-2">
        <Upload size={20} className="md:w-6 md:h-6" />
        Publish to Community
      </h2>

      <div className="space-y-4">
        <div>
          <label className="block text-sm font-medium mb-1">
            Level Name <span className="text-red-500">*</span>
          </label>
          <input
            type="text"
            value={levelName}
            onChange={(e) => setLevelName(e.target.value)}
            placeholder="My Amazing Level"
            className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
            maxLength={50}
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">
            Your Name <span className="text-red-500">*</span>
          </label>
          <input
            type="text"
            value={authorName}
            onChange={(e) => setAuthorName(e.target.value)}
            placeholder="Creator Name"
            className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
            maxLength={50}
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Description</label>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Describe your level strategy..."
            className="w-full px-3 py-2 border rounded h-24 resize-none focus:ring-2 focus:ring-blue-500"
            maxLength={500}
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Difficulty</label>
          <select
            value={difficulty}
            onChange={(e) => setDifficulty(e.target.value)}
            className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
          >
            <option>Easy</option>
            <option>Medium</option>
            <option>Hard</option>
            <option>Expert</option>
          </select>
        </div>

        <button
          onClick={handlePublish}
          disabled={isPublishing || !levelName.trim() || !authorName.trim()}
          className="w-full py-3 bg-green-500 text-white rounded-lg font-semibold hover:bg-green-600 transition disabled:bg-gray-300 disabled:cursor-not-allowed"
        >
          {isPublishing ? 'Publishing...' : 'Publish Level'}
        </button>

        <div className="mt-4 p-3 bg-blue-50 border border-blue-200 rounded flex gap-2">
          <AlertCircle size={16} className="text-blue-700 flex-shrink-0 mt-0.5" />
          <p className="text-xs text-blue-800">
            Ensure your level has exactly one player spawn and at least one goal mask!
          </p>
        </div>
      </div>
    </div>
  );
};
