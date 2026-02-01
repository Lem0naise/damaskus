import type { Level } from '../types/level';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5678/webhook';
const API_AUTH_TOKEN = import.meta.env.VITE_API_AUTH_TOKEN || '9JnwJyoeqJ6E8bRf';

interface PublishRequest {
  level: Level;
  metadata: {
    authorName: string;
    description: string;
    difficulty: string;
    tags: string[];
  };
}

interface PublishResponse {
  success: boolean;
  levelId: string;
  message?: string;
  error?: string;
}

export const publishLevel = async (data: PublishRequest): Promise<PublishResponse> => {
  try {
    console.log('Publishing to:', `${API_BASE_URL}/levels/publish`);
    console.log('Request data:', { level: data.level, metadata: data.metadata });

    const response = await fetch(`${API_BASE_URL}/levels/publish`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': API_AUTH_TOKEN,
      },
      body: JSON.stringify({
        level: {
          id: crypto.randomUUID(), // Generate new UUID for each publish
          name: data.level.name,
          levelLayout: data.level.levelLayout,
          maskLayout: data.level.maskLayout,
        },
        metadata: data.metadata,
      }),
    });

    console.log('Response status:', response.status);

    // Get response text first to debug
    const responseText = await response.text();
    console.log('Response body:', responseText);

    if (!response.ok) {
      let errorMessage = 'Publish failed';
      try {
        const errorData = JSON.parse(responseText);
        errorMessage = errorData.error || errorData.message || `Server error: ${response.status}`;
      } catch {
        errorMessage = `Server error: ${response.status} ${response.statusText}`;
      }
      throw new Error(errorMessage);
    }

    // Parse the JSON
    if (!responseText || responseText.trim() === '') {
      throw new Error('Server returned empty response. Check n8n workflow "Respond to Webhook" node.');
    }

    try {
      const result = JSON.parse(responseText);
      console.log('Success:', result);
      return result;
    } catch (parseError) {
      console.error('Failed to parse response:', responseText);
      throw new Error(`Invalid JSON response from server: ${responseText.substring(0, 100)}`);
    }
  } catch (error: any) {
    console.error('Publish error:', error);

    // Provide more helpful error messages
    if (error.message === 'Failed to fetch') {
      throw new Error('Cannot reach server. Check:\n1. Is n8n running?\n2. Is the URL correct?\n3. CORS enabled?');
    }

    throw error;
  }
};
