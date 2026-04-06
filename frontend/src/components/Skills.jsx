import { motion } from 'framer-motion';

const skillCategories = [
  {
    title: 'Cloud Platforms',
    color: 'from-cyan-400 to-blue-500',
    skills: [
      { name: 'Google Cloud', level: 90 },
      { name: 'AWS', level: 85 },
      { name: 'Firebase', level: 75 },
    ],
  },
  {
    title: 'Infrastructure as Code',
    color: 'from-violet-400 to-purple-500',
    skills: [
      { name: 'Terraform', level: 92 },
      { name: 'Cloud Build', level: 78 },
      { name: 'Cloud CDN', level: 75 },
    ],
  },
  {
    title: 'DevOps & CI/CD',
    color: 'from-emerald-400 to-teal-500',
    skills: [
      { name: 'GitHub Actions', level: 88 },
      { name: 'Docker', level: 82 },
      { name: 'Linux', level: 80 },
    ],
  },
  {
    title: 'Languages & Tools',
    color: 'from-orange-400 to-red-500',
    skills: [
      { name: 'Python', level: 85 },
      { name: 'Bash', level: 80 },
      { name: 'JavaScript', level: 72 },
    ],
  },
];

const Skills = () => {
  return (
    <section id="skills" className="relative">
      <div className="section-container">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-100px' }}
          transition={{ duration: 0.6 }}
          className="text-center"
        >
          <h2 className="section-title">
            Technical <span className="gradient-text">Skills</span>
          </h2>
          <p className="section-subtitle">
            Technologies and tools I use to build and automate cloud infrastructure
          </p>
        </motion.div>

        <div className="grid md:grid-cols-2 gap-6">
          {skillCategories.map((category, catIndex) => (
            <motion.div
              key={category.title}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-50px' }}
              transition={{ duration: 0.5, delay: catIndex * 0.15 }}
              className="glass-hover p-6"
            >
              <h3 className="text-lg font-semibold text-white mb-5 flex items-center gap-2">
                <span className={`w-2 h-2 rounded-full bg-gradient-to-r ${category.color}`} />
                {category.title}
              </h3>

              <div className="space-y-4">
                {category.skills.map((skill, skillIndex) => (
                  <div key={skill.name}>
                    <div className="flex justify-between items-center mb-1.5">
                      <span className="text-sm text-gray-300">{skill.name}</span>
                      <span className="text-xs text-gray-500 font-mono">{skill.level}%</span>
                    </div>
                    <div className="h-1.5 bg-dark-500 rounded-full overflow-hidden">
                      <motion.div
                        initial={{ width: 0 }}
                        whileInView={{ width: `${skill.level}%` }}
                        viewport={{ once: true }}
                        transition={{
                          duration: 1,
                          delay: catIndex * 0.15 + skillIndex * 0.1 + 0.3,
                          ease: 'easeOut',
                        }}
                        className={`h-full rounded-full bg-gradient-to-r ${category.color}`}
                      />
                    </div>
                  </div>
                ))}
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Skills;
