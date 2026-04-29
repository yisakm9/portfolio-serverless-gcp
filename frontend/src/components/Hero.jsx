import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';

const roles = [
  'Web Designer',
  'Cloud Engineer',
  'UI/UX Enthusiast',
  'DevOps Specialist',
];

const Hero = () => {
  const [roleIndex, setRoleIndex] = useState(0);
  const [displayText, setDisplayText] = useState('');
  const [isDeleting, setIsDeleting] = useState(false);

  useEffect(() => {
    const currentRole = roles[roleIndex];
    let timeout;

    if (!isDeleting && displayText === currentRole) {
      timeout = setTimeout(() => setIsDeleting(true), 2000);
    } else if (isDeleting && displayText === '') {
      setIsDeleting(false);
      setRoleIndex((prev) => (prev + 1) % roles.length);
    } else {
      timeout = setTimeout(() => {
        setDisplayText(
          isDeleting
            ? currentRole.substring(0, displayText.length - 1)
            : currentRole.substring(0, displayText.length + 1)
        );
      }, isDeleting ? 40 : 80);
    }

    return () => clearTimeout(timeout);
  }, [displayText, isDeleting, roleIndex]);

  return (
    <section className="relative min-h-screen flex items-center justify-center mesh-gradient dot-pattern overflow-hidden">
      {/* Floating orbs */}
      <div className="absolute top-1/4 left-1/4 w-72 h-72 bg-accent-cyan/10 rounded-full blur-[100px] animate-float" />
      <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-accent-violet/10 rounded-full blur-[120px] animate-float-delayed" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-accent-blue/5 rounded-full blur-[150px] animate-pulse-slow" />

      {/* Content */}
      <div className="relative z-10 text-center px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: 'easeOut' }}
        >
          {/* Status badge */}
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.2, duration: 0.5 }}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass mb-8"
          >
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            <span className="text-sm text-gray-300">Available for new opportunities</span>
          </motion.div>

          {/* Name */}
          <h1 className="text-5xl md:text-7xl font-bold mb-6">
            <span className="text-white">Yisak </span>
            <span className="gradient-text">Mesifin</span>
          </h1>

          {/* Typing role */}
          <div className="h-12 flex items-center justify-center mb-8">
            <span className="text-xl md:text-2xl text-gray-400 font-light">
              {displayText}
              <span className="inline-block w-[2px] h-6 bg-accent-cyan ml-1 animate-pulse" />
            </span>
          </div>

          {/* Description */}
          <p className="text-gray-400 text-lg max-w-xl mx-auto mb-10 leading-relaxed">
            Crafting <span className="text-white font-medium">beautiful</span> user interfaces and building <span className="text-white font-medium">serverless</span>,{' '}
            <span className="text-white font-medium">scalable</span> infrastructure on{' '}
            <span className="text-accent-cyan">GCP</span> &{' '}
            <span className="text-accent-violet">AWS</span>.
          </p>

          {/* CTAs */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4, duration: 0.6 }}
            className="flex flex-col sm:flex-row items-center justify-center gap-4"
          >
            <a href="#projects" className="btn-glow">
              View Projects
            </a>
            <a
              href="/Yisak_Mesifin_CV.pdf"
              download
              className="btn-outline flex items-center gap-2"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              Download CV
            </a>
            <a href="#contact" className="btn-outline">
              Get in Touch
            </a>
          </motion.div>
        </motion.div>

        {/* Scroll indicator */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.5 }}
          className="absolute bottom-8 left-1/2 -translate-x-1/2"
        >
          <motion.div
            animate={{ y: [0, 8, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="w-6 h-10 rounded-full border-2 border-white/20 flex items-start justify-center pt-2"
          >
            <div className="w-1 h-2 rounded-full bg-accent-cyan" />
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
};

export default Hero;
