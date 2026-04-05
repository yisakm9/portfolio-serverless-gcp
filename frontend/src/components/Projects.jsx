import { useEffect, useState } from 'react';
import axios from 'axios';

const Projects = () => {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchProjects = async () => {
      try {
        // GCP: Each Cloud Function has its own URL
        const projectsUrl = import.meta.env.VITE_API_PROJECTS_URL;
        
        // Safety Check: If URL is missing, stop early
        if (!projectsUrl) {
          throw new Error("Projects API URL is not defined");
        }

        const response = await axios.get(projectsUrl);
        
        // Safety Check: Ensure we actually got a list (Array)
        if (Array.isArray(response.data)) {
          setProjects(response.data);
        } else {
          console.error("API returned unexpected data format:", response.data);
          setProjects([]); 
        }

      } catch (err) {
        console.error("Error fetching projects:", err);
        setError("Could not load projects at this time.");
      } finally {
        setLoading(false);
      }
    };

    fetchProjects();
  }, []);

  if (loading) return <div className="text-center p-10">Loading Cloud Projects...</div>;
  
  if (error) return <div className="text-center p-10 text-red-500">{error}</div>;

  return (
    <section className="py-12 bg-white" id="projects">
      <div className="max-w-6xl mx-auto px-4">
        <h2 className="text-3xl font-bold text-gray-800 mb-8 text-center">Featured Cloud Projects</h2>
        
        {projects.length === 0 && (
           <p className="text-center text-gray-500">No projects found (or connecting to GitHub...)</p>
        )}

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {Array.isArray(projects) && projects.map((project) => (
            <div key={project.id} className="border rounded-lg p-6 shadow hover:shadow-lg transition">
              <h3 className="text-xl font-semibold text-blue-600 mb-2">{project.name}</h3>
              <p className="text-gray-600 mb-4 h-20 overflow-hidden">{project.description}</p>
              
              <div className="flex justify-between items-center mt-4">
                <span className="bg-gray-100 text-gray-800 text-xs px-2 py-1 rounded">
                  {project.language || "Terraform"}
                </span>
                <div className="flex items-center text-yellow-500 font-bold text-sm">
                  ★ {project.stars}
                </div>
              </div>
              
              <a 
                href={project.html_url} 
                target="_blank" 
                rel="noopener noreferrer"
                className="block mt-4 text-center bg-gray-900 text-white py-2 rounded hover:bg-gray-700"
              >
                View on GitHub
              </a>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Projects;