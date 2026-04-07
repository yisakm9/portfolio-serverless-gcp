import { motion } from 'framer-motion';

const testimonials = [
  {
    name: 'Cloud Infrastructure',
    role: 'Professional Approach',
    text: "Every project follows Infrastructure as Code principles — version-controlled, reproducible, and deployed through automated CI/CD pipelines. No manual clicks, no snowflake servers.",
    avatar: '🏗️',
  },
  {
    name: 'Security First',
    role: 'Best Practices',
    text: "Keyless authentication with Workload Identity Federation, least-privilege IAM roles, secrets stored in Secret Manager, and Google-managed SSL certificates. Security is never an afterthought.",
    avatar: '🔒',
  },
  {
    name: 'Full Automation',
    role: 'DevOps Culture',
    text: "From a single bootstrap script to production deployment — everything is automated. Push to main, and the entire infrastructure, backend, and frontend deploy in under 5 minutes.",
    avatar: '🚀',
  },
];

const Testimonials = () => {
  return (
    <section id="approach" className="relative">
      <div className="section-container">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-100px' }}
          transition={{ duration: 0.6 }}
          className="text-center"
        >
          <h2 className="section-title">
            My <span className="gradient-text">Approach</span>
          </h2>
          <p className="section-subtitle">
            Core principles that guide every project I build
          </p>
        </motion.div>

        <div className="grid md:grid-cols-3 gap-6">
          {testimonials.map((item, i) => (
            <motion.div
              key={item.name}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-50px' }}
              transition={{ duration: 0.5, delay: i * 0.15 }}
              className="glass-hover p-6 flex flex-col"
            >
              {/* Quote icon */}
              <svg className="w-8 h-8 text-accent-cyan/30 mb-4" fill="currentColor" viewBox="0 0 24 24">
                <path d="M14.017 21v-7.391c0-5.704 3.731-9.57 8.983-10.609l.995 2.151c-2.432.917-3.995 3.638-3.995 5.849h4v10H14.017zM0 21v-7.391c0-5.704 3.748-9.57 9-10.609l.996 2.151C7.563 6.068 6 8.789 6 11h4v10H0z" />
              </svg>

              {/* Text */}
              <p className="text-gray-300 text-sm leading-relaxed mb-6 flex-grow italic">
                "{item.text}"
              </p>

              {/* Author */}
              <div className="flex items-center gap-3 pt-4 border-t border-white/5">
                <div className="w-10 h-10 rounded-full glass flex items-center justify-center text-lg">
                  {item.avatar}
                </div>
                <div>
                  <div className="text-white text-sm font-semibold">{item.name}</div>
                  <div className="text-gray-500 text-xs">{item.role}</div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Testimonials;
