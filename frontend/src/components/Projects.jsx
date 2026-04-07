import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import axios from 'axios';
import ProjectModal from './ProjectModal';

const languageColors = {
  Python: 'bg-yellow-400',
  JavaScript: 'bg-yellow-300',
  TypeScript: 'bg-blue-400',
  HCL: 'bg-violet-400',
  Terraform: 'bg-violet-400',
  Go: 'bg-cyan-400',
  Shell: 'bg-emerald-400',
  Dockerfile: 'bg-blue-500',
};

const Projects = () => {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedProject, setSelectedProject] = useState(null);

  useEffect(() => {
    const fetchProjects = async () => {
      try {
        const projectsUrl = import.meta.env.VITE_API_PROJECTS_URL;
        if (!projectsUrl) throw new Error('Projects API URL is not defined');

        const response = await axios.get(projectsUrl);
        if (Array.isArray(response.data)) {
          setProjects(response.data);
        } else {
          setProjects([]);
        }
      } catch (err) {
        console.error('Error fetching projects:', err);
        setError('Could not load projects at this time.');
      } finally {
        setLoading(false);
      }
    };
    fetchProjects();
  }, []);

  return (
    <section id="projects" className="relative dot-pattern">
      <div className="section-container">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-100px' }}
          transition={{ duration: 0.6 }}
          className="text-center"
        >
          <h2 className="section-title">
            More on <span className="gradient-text">GitHub</span>
          </h2>
          <p className="section-subtitle">
            All repositories — fetched live from the GitHub API
          </p>
        </motion.div>

        {/* Loading skeleton */}
        {loading && (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="glass p-6 animate-pulse">
                <div className="h-6 bg-dark-500 rounded w-3/4 mb-4" />
                <div className="h-4 bg-dark-500 rounded w-full mb-2" />
                <div className="h-4 bg-dark-500 rounded w-5/6 mb-6" />
                <div className="h-8 bg-dark-500 rounded w-1/3" />
              </div>
            ))}
          </div>
        )}

        {/* Error */}
        {error && (
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="glass p-8 text-center">
            <p className="text-red-400">{error}</p>
          </motion.div>
        )}

        {/* No projects */}
        {!loading && !error && projects.length === 0 && (
          <div className="glass p-8 text-center">
            <p className="text-gray-400">No projects found. Connecting to GitHub...</p>
          </div>
        )}

        {/* Project cards */}
        {!loading && !error && projects.length > 0 && (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {projects.map((project, i) => (
              <motion.div
                key={project.id}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: '-50px' }}
                transition={{ duration: 0.5, delay: i * 0.1 }}
                className="glass-hover p-6 flex flex-col group cursor-pointer"
                onClick={() => setSelectedProject(project)}
              >
                {/* Header */}
                <div className="flex items-start justify-between mb-3">
                  <div className="text-accent-cyan">
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5}
                        d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" />
                    </svg>
                  </div>
                  <div className="flex items-center gap-1 text-yellow-400 text-sm">
                    <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                    </svg>
                    {project.stars}
                  </div>
                </div>

                {/* Title */}
                <h3 className="text-lg font-semibold text-white mb-2 group-hover:text-accent-cyan transition-colors duration-300">
                  {project.name}
                </h3>

                {/* Description */}
                <p className="text-gray-400 text-sm leading-relaxed mb-4 flex-grow line-clamp-3">
                  {project.description || 'No description provided.'}
                </p>

                {/* Footer */}
                <div className="flex items-center justify-between mt-auto pt-4 border-t border-white/5">
                  <div className="flex items-center gap-2">
                    <span className={`w-3 h-3 rounded-full ${languageColors[project.language] || 'bg-gray-400'}`} />
                    <span className="text-xs text-gray-400">{project.language || 'Terraform'}</span>
                  </div>
                  <span className="text-xs text-gray-500 group-hover:text-accent-cyan transition-colors duration-300 flex items-center gap-1">
                    View Details
                    <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </span>
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </div>

      {/* Project Detail Modal */}
      {selectedProject && (
        <ProjectModal project={selectedProject} onClose={() => setSelectedProject(null)} />
      )}
    </section>
  );
};

export default Projects;