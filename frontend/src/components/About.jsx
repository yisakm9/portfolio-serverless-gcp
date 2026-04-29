import { motion } from 'framer-motion';

const stats = [
  { value: '5+', label: 'Cloud Projects', icon: '☁️' },
  { value: '2+', label: 'Years Learning', icon: '📚' },
  { value: '5+', label: 'Technologies', icon: '⚙️' },
  { value: '100%', label: 'IaC Coverage', icon: '🔧' },
];

const About = () => {
  return (
    <section id="about" className="relative dot-pattern">
      <div className="section-container">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-100px' }}
          transition={{ duration: 0.6 }}
          className="text-center"
        >
          <h2 className="section-title">
            About <span className="gradient-text">Me</span>
          </h2>
          <p className="section-subtitle">
            Passionate about crafting intuitive user interfaces and building resilient cloud infrastructure
          </p>
        </motion.div>

        <div className="grid md:grid-cols-2 gap-12 items-center">
          {/* Bio */}
          <motion.div
            initial={{ opacity: 0, x: -40 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: '-100px' }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            <div className="glass p-8">
              <p className="text-gray-300 leading-relaxed mb-4">
                I'm a <span className="text-white font-semibold">Web Designer & Cloud Engineer</span> specializing in
                creating <span className="text-accent-cyan">beautiful user experiences</span> and implementing{' '}
                <span className="text-accent-violet">automated infrastructure</span> on Google Cloud Platform and AWS.
              </p>
              <p className="text-gray-300 leading-relaxed mb-4">
                My approach is <span className="text-white font-semibold">Infrastructure as Code first</span> —
                every resource is version-controlled, reproducible, and deployed through CI/CD pipelines.
                No manual clicks, no snowflake servers.
              </p>
              <p className="text-gray-300 leading-relaxed">
                Currently building modern web applications and production-grade serverless systems with{' '}
                <span className="text-accent-cyan">React & Tailwind</span>,{' '}
                <span className="text-accent-violet">Terraform</span>,{' '}
                <span className="text-accent-blue">Docker</span>, and{' '}
                <span className="text-emerald-400">GitHub Actions</span>.
              </p>
            </div>
          </motion.div>

          {/* Stats Grid */}
          <motion.div
            initial={{ opacity: 0, x: 40 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: '-100px' }}
            transition={{ duration: 0.6, delay: 0.4 }}
            className="grid grid-cols-2 gap-4"
          >
            {stats.map((stat, i) => (
              <motion.div
                key={stat.label}
                initial={{ opacity: 0, scale: 0.8 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: 0.5 + i * 0.1 }}
                className="glass-hover p-6 text-center"
              >
                <div className="text-3xl mb-2">{stat.icon}</div>
                <div className="text-2xl font-bold gradient-text mb-1">{stat.value}</div>
                <div className="text-sm text-gray-400">{stat.label}</div>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default About;
