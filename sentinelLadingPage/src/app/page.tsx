"use client";

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Download,
  Zap,
  Globe,
  BellOff,
  Heart,
  ChevronRight,
  Apple,
  Github,
  Info,
} from "lucide-react";
import i18n, { Lang } from "@/i18n/t";

const rise = (d = 0) => ({
  hidden: { opacity: 0, y: 32 },
  show: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.7, delay: d, ease: [0.22, 1, 0.36, 1] },
  },
});

export default function Home() {
  const [lang, setLang] = useState<Lang>("en");
  const [ctaNudge, setCtaNudge] = useState(false);
  const t = i18n[lang];

  useEffect(() => {
    const timer = setTimeout(() => setCtaNudge(true), 3000);
    return () => clearTimeout(timer);
  }, []);

  useEffect(() => {
    if (ctaNudge) {
      const reset = setTimeout(() => setCtaNudge(false), 1000);
      return () => clearTimeout(reset);
    }
  }, [ctaNudge]);

  const langs: { code: Lang; label: string }[] = [
    { code: "en", label: "EN" },
    { code: "es", label: "ES" },
    { code: "fr", label: "FR" },
  ];

  const features = [
    { icon: <Zap className="w-5 h-5" />, title: t.f1, desc: t.f1d, color: "text-amber-400", bg: "bg-amber-400/10" },
    { icon: <Globe className="w-5 h-5" />, title: t.f2, desc: t.f2d, color: "text-blue-400", bg: "bg-blue-400/10" },
    { icon: <BellOff className="w-5 h-5" />, title: t.f3, desc: t.f3d, color: "text-rose-400", bg: "bg-rose-400/10" },
    { icon: <Heart className="w-5 h-5" />, title: t.f4, desc: t.f4d, color: "text-emerald-400", bg: "bg-emerald-400/10" },
  ];

  return (
    <div className="relative min-h-screen overflow-hidden" style={{ background: "var(--bg)", color: "var(--text)" }}>
      {/* Background Orbs */}
      <div className="orb orb-blue w-[600px] h-[600px] -top-48 -left-40" />
      <div className="orb orb-green w-[500px] h-[500px] top-[40%] -right-32" />
      <div className="orb orb-purple w-[400px] h-[400px] bottom-[-10%] left-[25%]" />

      {/* ── Nav ── */}
      <nav className="relative z-30 mx-auto flex max-w-5xl items-center justify-between px-6 py-5">
        <span className="text-[15px] font-bold tracking-tight">⛨ Sentinel</span>
        <div className="flex items-center gap-4">
          <a
            href="https://github.com/mauneven/Sentinel"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-1.5 text-xs font-medium transition-opacity hover:opacity-70"
            style={{ color: "var(--muted)" }}
          >
            <Github className="w-4 h-4" />
            {t.ghLink}
          </a>
          <div className="flex gap-1 rounded-full border p-1" style={{ borderColor: "var(--border)", background: "var(--surface)" }}>
            {langs.map((l) => (
              <button
                key={l.code}
                onClick={() => setLang(l.code)}
                className="rounded-full px-3 py-1 text-xs font-semibold transition-all duration-200"
                style={{
                  background: lang === l.code ? "var(--btn-bg)" : "transparent",
                  color: lang === l.code ? "var(--btn-text)" : "var(--muted)",
                }}
              >
                {l.label}
              </button>
            ))}
          </div>
        </div>
      </nav>

      {/* ── Hero ── */}
      <section className="relative z-10 mx-auto flex max-w-3xl flex-col items-center px-6 pt-20 pb-16 text-center md:pt-32">
        {/* Badges */}
        <motion.div initial="hidden" animate="show" variants={rise(0)} className="mb-8 flex flex-wrap justify-center gap-2">
          {[t.badge1, t.badge2, t.badge3].map((badge) => (
            <span
              key={badge}
              className="inline-flex items-center rounded-full px-3.5 py-1 text-xs font-semibold"
              style={{ background: "var(--badge-bg)", border: "1px solid var(--badge-border)", color: "var(--muted)" }}
            >
              {badge}
            </span>
          ))}
        </motion.div>

        <motion.h1
          initial="hidden"
          animate="show"
          variants={rise(0.1)}
          className="text-5xl font-extrabold leading-[1.1] tracking-tight sm:text-6xl md:text-7xl"
        >
          <AnimatePresence mode="wait">
            <motion.span
              key={lang + "-h1"}
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -8 }}
              transition={{ duration: 0.3 }}
            >
              {t.h1}{" "}
              <span className="text-shimmer">{t.h1_accent}</span>
            </motion.span>
          </AnimatePresence>
        </motion.h1>

        <motion.p
          initial="hidden"
          animate="show"
          variants={rise(0.2)}
          className="mt-6 max-w-xl text-base leading-relaxed md:text-lg"
          style={{ color: "var(--muted)" }}
        >
          <AnimatePresence mode="wait">
            <motion.span
              key={lang + "-sub"}
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.25 }}
            >
              {t.sub}
            </motion.span>
          </AnimatePresence>
        </motion.p>

        <motion.div
          initial="hidden"
          animate="show"
          variants={rise(0.35)}
          className="mt-10 flex flex-col items-center gap-3 sm:flex-row sm:gap-4"
        >
          <a
            href="/Sentinel.zip"
            download
            className={`group flex items-center gap-2.5 rounded-xl px-7 py-3.5 text-[15px] font-semibold transition-all duration-200 hover:scale-[1.03] ${ctaNudge ? "cta-nudge" : ""}`}
            style={{
              background: "var(--btn-bg)",
              color: "var(--btn-text)",
              boxShadow: `0 0 40px var(--btn-glow), 0 1px 3px rgba(0,0,0,0.2)`,
            }}
          >
            <Apple className="w-4.5 h-4.5" />
            {t.cta}
            <ChevronRight className="w-4 h-4 opacity-50 group-hover:translate-x-0.5 transition-transform" />
          </a>
          <span className="text-xs font-medium" style={{ color: "var(--muted)" }}>
            {t.req}
          </span>
        </motion.div>
      </section>

      {/* ── App Preview ── */}
      <motion.section
        initial={{ opacity: 0, y: 48 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
        className="relative z-10 mx-auto max-w-3xl px-6 pb-24"
      >
        <div className="overflow-hidden rounded-2xl" style={{ border: "1px solid var(--border)", background: "var(--surface)" }}>
          <div className="flex items-center gap-2 px-4 py-3" style={{ borderBottom: "1px solid var(--border)" }}>
            <span className="h-3 w-3 rounded-full" style={{ background: "#ff5f57" }} />
            <span className="h-3 w-3 rounded-full" style={{ background: "#febc2e" }} />
            <span className="h-3 w-3 rounded-full" style={{ background: "#28c840" }} />
            <span className="ml-3 text-[11px] font-medium" style={{ color: "var(--muted)" }}>Sentinel</span>
          </div>
          <div className="relative aspect-video w-full overflow-hidden flex items-center justify-center" style={{ background: "var(--bg-subtle)" }}>
            <AnimatePresence mode="wait">
              <motion.img
                key={lang}
                src={`/screenshots/${lang}.png`}
                alt={t.preview}
                initial={{ opacity: 0, scale: 0.98 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 1.02 }}
                transition={{ duration: 0.35 }}
                className="h-full w-full object-contain"
                onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }}
              />
            </AnimatePresence>
            <div className="absolute inset-0 flex flex-col items-center justify-center gap-2" style={{ color: "var(--muted)" }}>
              <span className="text-3xl">⛨</span>
              <span className="text-sm font-medium">{t.preview}</span>
            </div>
          </div>
        </div>
      </motion.section>

      {/* ── Features ── */}
      <section className="relative z-10 mx-auto max-w-4xl px-6 pb-24">
        <div className="grid gap-4 sm:grid-cols-2">
          {features.map((f, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: i * 0.08 }}
              className="group rounded-2xl p-6 transition-all duration-200 cursor-default"
              style={{ background: "var(--surface)", border: "1px solid var(--border)" }}
              onMouseEnter={(e) => {
                (e.currentTarget as HTMLDivElement).style.background = "var(--card-hover)";
                (e.currentTarget as HTMLDivElement).style.borderColor = "rgba(128,128,128,0.2)";
              }}
              onMouseLeave={(e) => {
                (e.currentTarget as HTMLDivElement).style.background = "var(--surface)";
                (e.currentTarget as HTMLDivElement).style.borderColor = "var(--border)";
              }}
            >
              <div className={`mb-4 inline-flex h-10 w-10 items-center justify-center rounded-xl ${f.bg} ${f.color}`}>
                {f.icon}
              </div>
              <h3 className="mb-2 text-[17px] font-bold">{f.title}</h3>
              <p className="text-sm leading-relaxed" style={{ color: "var(--muted)" }}>{f.desc}</p>
            </motion.div>
          ))}
        </div>
      </section>

      {/* ── Install Help ── */}
      <section className="relative z-10 mx-auto max-w-3xl px-6 pb-20">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="flex gap-4 rounded-2xl p-6"
          style={{ background: "var(--surface)", border: "1px solid var(--border)" }}
        >
          <Info className="w-5 h-5 flex-shrink-0 mt-0.5" style={{ color: "var(--muted)" }} />
          <div>
            <h3 className="text-[15px] font-bold mb-1">{t.install_title}</h3>
            <p className="text-sm leading-relaxed" style={{ color: "var(--muted)" }}>{t.install_desc}</p>
          </div>
        </motion.div>
      </section>

      {/* ── CTA ── */}
      <section className="relative z-10 mx-auto max-w-3xl px-6 pb-20">
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="rounded-2xl p-10 text-center md:p-14"
          style={{ background: "var(--surface)", border: "1px solid var(--border)" }}
        >
          <h2 className="text-2xl font-extrabold md:text-4xl">{t.cta2}</h2>
          <p className="mx-auto mt-4 max-w-md text-sm md:text-base" style={{ color: "var(--muted)" }}>{t.cta2d}</p>
          <a
            href="/Sentinel.zip"
            download
            className="mt-8 inline-flex items-center gap-2 rounded-xl px-7 py-3.5 text-[15px] font-semibold transition-all hover:scale-[1.03]"
            style={{ background: "var(--btn-bg)", color: "var(--btn-text)", boxShadow: `0 0 40px var(--btn-glow)` }}
          >
            <Download className="w-4 h-4" />
            {t.cta}
          </a>
        </motion.div>
      </section>

      {/* ── Footer ── */}
      <footer className="relative z-10 py-8 text-center" style={{ borderTop: "1px solid var(--border)" }}>
        <p className="text-xs" style={{ color: "var(--muted)" }}>
          © {new Date().getFullYear()} Sentinel · {t.footer}
        </p>
      </footer>
    </div>
  );
}
