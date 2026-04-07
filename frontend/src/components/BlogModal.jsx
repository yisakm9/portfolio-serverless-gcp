import { useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

/**
 * Simple markdown-like renderer.
 * Handles: ## headings, **bold**, `code`, paragraphs, and - lists.
 */
const renderContent = (content) => {
  const lines = content.split('\n');
  const elements = [];
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    // Heading ##
    if (line.startsWith('## ')) {
      elements.push(
        <h3 key={i} className="text-xl font-bold text-white mt-8 mb-3">
          {line.replace('## ', '')}
        </h3>
      );
    }
    // List item
    else if (line.startsWith('- **')) {
      const match = line.match(/^- \*\*(.+?)\*\*(.*)$/);
      if (match) {
        elements.push(
          <li key={i} className="text-gray-300 leading-relaxed ml-4 mb-1">
            <span className="text-white font-semibold">{match[1]}</span>
            {match[2]}
          </li>
        );
      }
    }
    // Regular list item
    else if (line.startsWith('- ')) {
      elements.push(
        <li key={i} className="text-gray-300 leading-relaxed ml-4 mb-1 list-disc list-inside">
          {line.replace('- ', '')}
        </li>
      );
    }
    // Code block (single line with backticks)
    else if (line.includes('`') && !line.startsWith('```')) {
      const parts = line.split(/(`[^`]+`)/g);
      elements.push(
        <p key={i} className="text-gray-300 leading-relaxed mb-4">
          {parts.map((part, j) =>
            part.startsWith('`') && part.endsWith('`') ? (
              <code key={j} className="px-1.5 py-0.5 rounded bg-dark-500 text-accent-cyan text-sm font-mono">
                {part.slice(1, -1)}
              </code>
            ) : (
              <span key={j}>{part}</span>
            )
          )}
        </p>
      );
    }
    // Error/code block line
    else if (line.startsWith('Error') || line.startsWith('  ')) {
      elements.push(
        <div key={i} className="bg-dark-700 rounded-lg p-3 mb-4 font-mono text-sm text-red-400 overflow-x-auto">
          {line}
        </div>
      );
    }
    // Empty line = paragraph break
    else if (line.trim() === '') {
      // skip
    }
    // Normal paragraph
    else {
      // Handle **bold** within text
      const parts = line.split(/(\*\*[^*]+\*\*)/g);
      elements.push(
        <p key={i} className="text-gray-300 leading-relaxed mb-4">
          {parts.map((part, j) =>
            part.startsWith('**') && part.endsWith('**') ? (
              <span key={j} className="text-white font-semibold">{part.slice(2, -2)}</span>
            ) : (
              <span key={j}>{part}</span>
            )
          )}
        </p>
      );
    }

    i++;
  }

  return elements;
};

const BlogModal = ({ post, onClose }) => {
  useEffect(() => {
    const handleEsc = (e) => {
      if (e.key === 'Escape') onClose();
    };
    document.addEventListener('keydown', handleEsc);
    document.body.style.overflow = 'hidden';
    return () => {
      document.removeEventListener('keydown', handleEsc);
      document.body.style.overflow = '';
    };
  }, [onClose]);

  if (!post) return null;

  const formattedDate = new Date(post.date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto"
        onClick={onClose}
      >
        {/* Backdrop */}
        <div className="fixed inset-0 bg-dark-900/85 backdrop-blur-sm" />

        {/* Modal */}
        <motion.article
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: 40 }}
          transition={{ duration: 0.3, ease: 'easeOut' }}
          className="relative w-full max-w-3xl my-8 mx-4 glass p-8 md:p-12 z-10"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Close button */}
          <button
            onClick={onClose}
            className="absolute top-4 right-4 text-gray-400 hover:text-white transition-colors p-2 rounded-lg hover:bg-white/5"
            aria-label="Close"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>

          {/* Header */}
          <header className="mb-8">
            <div className="flex flex-wrap gap-2 mb-4">
              {post.tags.map((tag) => (
                <span key={tag} className="px-3 py-1 rounded-full bg-accent-cyan/10 text-accent-cyan text-xs font-medium">
                  {tag}
                </span>
              ))}
            </div>
            <h1 className="text-2xl md:text-3xl font-bold text-white mb-3 leading-tight">
              {post.title}
            </h1>
            <div className="flex items-center gap-4 text-sm text-gray-500">
              <span>{formattedDate}</span>
              <span>·</span>
              <span>{post.readTime}</span>
            </div>
          </header>

          {/* Divider */}
          <div className="gradient-line mb-8" />

          {/* Content */}
          <div className="prose-custom">
            {renderContent(post.content)}
          </div>

          {/* Bottom nav */}
          <div className="mt-10 pt-6 border-t border-white/5">
            <button
              onClick={onClose}
              className="text-sm text-gray-400 hover:text-accent-cyan transition-colors flex items-center gap-2"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
              Back to all posts
            </button>
          </div>
        </motion.article>
      </motion.div>
    </AnimatePresence>
  );
};

export default BlogModal;
