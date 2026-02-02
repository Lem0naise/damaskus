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
    <div className="bg-sand-50 rounded-2xl shadow-sand border border-sand-200 p-4 md:p-6 w-full max-w-md">
      <h2 className="text-xl md:text-2xl font-bold mb-3 md:mb-4 flex items-center gap-2 text-sand-800">
        <Upload size={20} className="md:w-6 md:h-6 text-terracotta-500" />
        Publish to Community
      </h2>

      <div className="space-y-4">
        <div>
          <label className="block text-sm font-medium mb-1.5 text-sand-700">
            Level Name <span className="text-terracotta-500">*</span>
          </label>
          <input
            type="text"
            value={levelName}
            onChange={(e) => setLevelName(e.target.value)}
            placeholder="My Amazing Level"
            className="w-full px-3 py-2.5 border-2 border-sand-300 rounded-xl bg-white focus:ring-2 focus:ring-terracotta-500/30 focus:border-terracotta-500 transition-colors text-sand-800 placeholder:text-sand-400"
            maxLength={50}
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1.5 text-sand-700">
            Your Name <span className="text-terracotta-500">*</span>
          </label>
          <input
            type="text"
            value={authorName}
            onChange={(e) => setAuthorName(e.target.value)}
            placeholder="Creator Name"
            className="w-full px-3 py-2.5 border-2 border-sand-300 rounded-xl bg-white focus:ring-2 focus:ring-terracotta-500/30 focus:border-terracotta-500 transition-colors text-sand-800 placeholder:text-sand-400"
            maxLength={50}
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1.5 text-sand-700">Description</label>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Describe your level strategy..."
            className="w-full px-3 py-2.5 border-2 border-sand-300 rounded-xl h-24 resize-none bg-white focus:ring-2 focus:ring-terracotta-500/30 focus:border-terracotta-500 transition-colors text-sand-800 placeholder:text-sand-400"
            maxLength={500}
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1.5 text-sand-700">Difficulty</label>
          <select
            value={difficulty}
            onChange={(e) => setDifficulty(e.target.value)}
            className="w-full px-3 py-2.5 border-2 border-sand-300 rounded-xl bg-white focus:ring-2 focus:ring-terracotta-500/30 focus:border-terracotta-500 transition-colors text-sand-800"
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
          className="w-full py-3 bg-terracotta-500 text-white rounded-xl font-semibold hover:bg-terracotta-600 transition-all duration-200 shadow-sand hover:shadow-sand-lg disabled:bg-sand-300 disabled:cursor-not-allowed disabled:shadow-none"
        >
          {isPublishing ? 'Publishing...' : 'Publish Level'}
        </button>

        <div className="mt-4 p-3 bg-damascus-500/10 border border-damascus-500/20 rounded-xl flex gap-2">
          <AlertCircle size={16} className="text-damascus-600 flex-shrink-0 mt-0.5" />
          <p className="text-xs text-damascus-600">
            Ensure your level has exactly one player spawn and at least one goal mask!
          </p>
        </div>
      </div>
    </div>
  );
};
