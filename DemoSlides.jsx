import React, { useState, useEffect, useCallback } from "react";

// ─── Design Tokens ───
const colors = {
  brand: "#0069E0",
  brandLight: "#E8F2FD",
  brandDark: "#004BA0",
  accent: "#FF6B35",
  accentLight: "#FFF0EA",
  green: "#1A7F37",
  greenLight: "#DAFBE1",
  purple: "#8250DF",
  purpleLight: "#EDDCFF",
  textPrimary: "#1A1A2E",
  textSecondary: "#5A6376",
  textInverse: "#F0F2F5",
  border: "#E2E6EB",
  surfaceDim: "#F6F8FA",
};

const fonts = {
  sans: "'Inter', -apple-system, BlinkMacSystemFont, sans-serif",
  mono: "'JetBrains Mono', monospace",
};

// ─── Background presets ───
const bg = {
  dark: "linear-gradient(135deg, #0D1117 0%, #161B22 50%, #1A1F2B 100%)",
  light: "linear-gradient(180deg, #FFFFFF 0%, #F6F8FA 100%)",
  brand: "linear-gradient(135deg, #0069E0 0%, #004BA0 60%, #003875 100%)",
  gradient: "linear-gradient(135deg, #0D1117 0%, #0069E0 100%)",
};

// ─── Reusable tiny components ───
const Tag = ({ children, variant = "brand" }) => {
  const map = {
    brand: { bg: "rgba(0,105,224,0.15)", color: "#5BA3EF" },
    green: { bg: "rgba(26,127,55,0.15)", color: "#56D364" },
    accent: { bg: "rgba(255,107,53,0.15)", color: "#FF8C61" },
  };
  const s = map[variant];
  return (
    <div
      style={{
        display: "inline-block",
        fontSize: 13,
        fontWeight: 600,
        textTransform: "uppercase",
        letterSpacing: 1.5,
        padding: "6px 16px",
        borderRadius: 20,
        marginBottom: 20,
        background: s.bg,
        color: s.color,
      }}
    >
      {children}
    </div>
  );
};

const Kicker = ({ children }) => (
  <div
    style={{
      fontSize: 13,
      fontWeight: 600,
      textTransform: "uppercase",
      letterSpacing: 2.5,
      marginBottom: 20,
      opacity: 0.6,
    }}
  >
    {children}
  </div>
);

const Title = ({ children, style }) => (
  <div
    style={{
      fontSize: 56,
      fontWeight: 800,
      lineHeight: 1.1,
      letterSpacing: -1.5,
      maxWidth: 900,
      textAlign: "center",
      ...style,
    }}
  >
    {children}
  </div>
);

const SectionTitle = ({ children, style }) => (
  <div
    style={{
      fontSize: 42,
      fontWeight: 700,
      lineHeight: 1.2,
      letterSpacing: -1,
      maxWidth: 800,
      ...style,
    }}
  >
    {children}
  </div>
);

const Subtitle = ({ children, style }) => (
  <div
    style={{
      fontSize: 22,
      fontWeight: 400,
      lineHeight: 1.5,
      maxWidth: 680,
      textAlign: "center",
      marginTop: 20,
      opacity: 0.75,
      ...style,
    }}
  >
    {children}
  </div>
);

const CodeBlock = ({ children, style }) => (
  <pre
    style={{
      background: "rgba(0,0,0,0.3)",
      border: "1px solid rgba(255,255,255,0.1)",
      borderRadius: 12,
      padding: "28px 32px",
      fontFamily: fonts.mono,
      fontSize: 16,
      lineHeight: 1.7,
      maxWidth: 800,
      width: "100%",
      marginTop: 32,
      color: "#E6EDF3",
      whiteSpace: "pre-wrap",
      ...style,
    }}
  >
    {children}
  </pre>
);

const Cursor = () => (
  <span
    style={{
      display: "inline-block",
      width: 2,
      height: "1em",
      background: "#7EE787",
      marginLeft: 2,
      verticalAlign: "text-bottom",
      animation: "blink 1s step-end infinite",
    }}
  />
);

const Prompt = ({ children }) => (
  <span style={{ color: "#7EE787" }}>{children}</span>
);

const Comment = ({ children }) => (
  <span style={{ color: "#8B949E" }}>{children}</span>
);

const Highlight = ({ children }) => (
  <span style={{ color: "#79C0FF", fontWeight: 600 }}>{children}</span>
);

const TalkingPoint = ({ children, style }) => (
  <div
    style={{
      background: "rgba(255,255,255,0.06)",
      borderLeft: `3px solid ${colors.brand}`,
      borderRadius: "0 10px 10px 0",
      padding: "20px 28px",
      marginTop: 28,
      maxWidth: 760,
      width: "100%",
      ...style,
    }}
  >
    <div
      style={{
        fontSize: 11,
        fontWeight: 700,
        textTransform: "uppercase",
        letterSpacing: 2,
        opacity: 0.45,
        marginBottom: 8,
      }}
    >
      Say this
    </div>
    <p style={{ fontSize: 17, fontStyle: "italic", lineHeight: 1.6, opacity: 0.85 }}>
      {children}
    </p>
  </div>
);

const Card = ({ icon, iconBg, iconColor, title, desc, light }) => (
  <div
    style={{
      flex: 1,
      background: light ? "white" : "rgba(255,255,255,0.08)",
      backdropFilter: "blur(10px)",
      border: `1px solid ${light ? colors.border : "rgba(255,255,255,0.12)"}`,
      borderRadius: 16,
      padding: "32px 28px",
      display: "flex",
      flexDirection: "column",
      gap: 12,
      boxShadow: light
        ? "0 1px 3px rgba(0,0,0,0.06), 0 8px 24px rgba(0,0,0,0.04)"
        : "none",
    }}
  >
    <div
      style={{
        width: 48,
        height: 48,
        borderRadius: 12,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontSize: 22,
        marginBottom: 4,
        background: iconBg,
        color: iconColor,
      }}
    >
      {icon}
    </div>
    <div
      style={{
        fontSize: 18,
        fontWeight: 700,
        color: light ? colors.textPrimary : "white",
      }}
    >
      {title}
    </div>
    <div
      style={{
        fontSize: 15,
        fontWeight: 400,
        lineHeight: 1.5,
        color: light ? colors.textSecondary : "rgba(255,255,255,0.55)",
      }}
    >
      {desc}
    </div>
  </div>
);

const Stat = ({ value, label }) => (
  <div style={{ textAlign: "center" }}>
    <div style={{ fontSize: 52, fontWeight: 800, letterSpacing: -2, lineHeight: 1 }}>
      {value}
    </div>
    <div
      style={{
        fontSize: 15,
        fontWeight: 500,
        opacity: 0.6,
        marginTop: 8,
        textTransform: "uppercase",
        letterSpacing: 1,
      }}
    >
      {label}
    </div>
  </div>
);

// ─── Slide wrapper ───
const Slide = ({ background, align = "center", color = colors.textInverse, children }) => (
  <div
    style={{
      width: "100%",
      height: "100%",
      display: "flex",
      flexDirection: "column",
      justifyContent: "center",
      alignItems: align === "left" ? "flex-start" : "center",
      textAlign: align,
      padding: "60px 80px",
      background,
      color,
      fontFamily: fonts.sans,
      position: "relative",
    }}
  >
    {children}
  </div>
);

const SlideNumber = ({ n, total = 12, style }) => (
  <div
    style={{
      position: "absolute",
      bottom: 28,
      right: 40,
      fontSize: 13,
      fontWeight: 500,
      opacity: 0.4,
      fontFamily: fonts.mono,
      letterSpacing: 0.5,
      ...style,
    }}
  >
    {n} / {total}
  </div>
);

// ─── All slides ───
const slides = [
  // 0 — Title
  () => (
    <Slide background={bg.dark}>
      <Kicker>Demo Session</Kicker>
      <Title>
        How I Ship Features
        <br />
        with Claude Code
      </Title>
      <Subtitle>From user story to pull request — a walkthrough on REPortfolio-iOS</Subtitle>
      <div style={{ display: "flex", gap: 60, marginTop: 48 }}>
        <Stat value="2.4k" label="Lines of Swift" />
        <Stat value="21" label="UI Components" />
        <Stat value="5" label="Screens" />
      </div>
      <SlideNumber n={0} />
    </Slide>
  ),

  // 1 — The App
  () => (
    <Slide background={bg.light} align="left" color={colors.textPrimary}>
      <Tag variant="brand">The Product</Tag>
      <SectionTitle>REPortfolio</SectionTitle>
      <div style={{ fontSize: 20, lineHeight: 1.7, marginTop: 16, color: colors.textSecondary }}>
        A real estate portfolio tracker built for Indian property investors.
      </div>
      <div style={{ display: "flex", gap: 24, marginTop: 36, width: "100%", maxWidth: 1000 }}>
        <Card
          light
          icon={"\u{1F3E0}"}
          iconBg={colors.brandLight}
          iconColor={colors.brand}
          title="Track Properties"
          desc="Add properties across cities. Get live valuations from 99acres market data."
        />
        <Card
          light
          icon={"\u{1F4C8}"}
          iconBg={colors.greenLight}
          iconColor={colors.green}
          title="Compare Returns"
          desc="See how your property appreciation stacks up against Gold and Nifty benchmarks."
        />
        <Card
          light
          icon={"\u{1F4B0}"}
          iconBg={colors.accentLight}
          iconColor={colors.accent}
          title="Monitor Rent"
          desc="Track rental yields, tenant demand, and monthly income across your portfolio."
        />
      </div>
      <SlideNumber n={1} style={{ color: colors.textSecondary }} />
    </Slide>
  ),

  // 2 — The Problem
  () => (
    <Slide background={bg.dark} align="left">
      <Tag variant="accent">The Challenge</Tag>
      <SectionTitle>
        Shipping features
        <br />
        takes too long
      </SectionTitle>
      <div style={{ display: "flex", gap: 32, marginTop: 36, width: "100%", maxWidth: 900 }}>
        {/* Before */}
        <div
          style={{
            flex: 1,
            borderRadius: 16,
            padding: 32,
            background: "rgba(255,255,255,0.05)",
            border: "1px solid rgba(255,255,255,0.1)",
          }}
        >
          <h3
            style={{
              fontSize: 14,
              fontWeight: 600,
              textTransform: "uppercase",
              letterSpacing: 2,
              marginBottom: 20,
              opacity: 0.6,
            }}
          >
            Traditional Flow
          </h3>
          {[
            "Write a ticket with requirements",
            "Wait for sprint planning",
            "Developer picks it up",
            "Back-and-forth on specs",
            "Code review cycles",
            "Finally merged... days later",
          ].map((t) => (
            <div key={t} style={{ fontSize: 17, lineHeight: 1.4, paddingLeft: 24, marginBottom: 14, position: "relative" }}>
              <span style={{ position: "absolute", left: 0, color: "#F85149", fontWeight: 700 }}>{"\u2717"}</span>
              {t}
            </div>
          ))}
        </div>
        {/* After */}
        <div
          style={{
            flex: 1,
            borderRadius: 16,
            padding: 32,
            background: "rgba(0,105,224,0.15)",
            border: "1px solid rgba(0,105,224,0.3)",
          }}
        >
          <h3
            style={{
              fontSize: 14,
              fontWeight: 600,
              textTransform: "uppercase",
              letterSpacing: 2,
              marginBottom: 20,
              opacity: 0.6,
            }}
          >
            With Claude Code
          </h3>
          {[
            "Describe what you want",
            "See it built in real-time",
            "Give feedback instantly",
            "Iterate in the same session",
            "Commit and ship",
            "Done in minutes",
          ].map((t) => (
            <div key={t} style={{ fontSize: 17, lineHeight: 1.4, paddingLeft: 24, marginBottom: 14, position: "relative" }}>
              <span style={{ position: "absolute", left: 0, color: "#56D364", fontWeight: 700 }}>{"\u2713"}</span>
              {t}
            </div>
          ))}
        </div>
      </div>
      <SlideNumber n={2} />
    </Slide>
  ),

  // 3 — What is Claude Code
  () => (
    <Slide background={bg.gradient}>
      <Kicker>The Tool</Kicker>
      <Title style={{ fontSize: 48 }}>
        Claude Code is a
        <br />
        coding partner in
        <br />
        your terminal
      </Title>
      <Subtitle>
        You describe what you want in plain English.
        <br />
        It reads your codebase, understands the context, and writes the code.
      </Subtitle>
      <SlideNumber n={3} />
    </Slide>
  ),

  // 4 — CLAUDE.md
  () => (
    <Slide background={bg.dark} align="left">
      <Tag variant="green">Step 1</Tag>
      <SectionTitle>Give it product context</SectionTitle>
      <div style={{ fontSize: 20, lineHeight: 1.7, marginTop: 12, opacity: 0.6 }}>
        CLAUDE.md is like a product brief for your AI teammate. It reads this every session.
      </div>
      <CodeBlock style={{ fontSize: 14 }}>
        <Comment># CLAUDE.md</Comment>
        {"\n\n"}
        <Highlight>REPortfolio-iOS</Highlight>
        {"\n"}Real estate portfolio tracker for Indian investors.{"\n"}Valuations from 99acres,
        compare with Gold/Nifty.{"\n\n"}
        <Highlight>Tech:</Highlight> SwiftUI · iOS 16+ · Supabase · XcodeGen{"\n"}
        <Highlight>Key:</Highlight>{"  "}PropertyRepository.shared holds all state{"\n"}
        {"       "}Design tokens in DesignSystem/{"\n"}
        {"       "}INR formatting (Lakhs, Crores)
      </CodeBlock>
      <TalkingPoint>
        "Think of this as onboarding a new team member — except it takes 2 seconds and they actually
        read everything."
      </TalkingPoint>
      <SlideNumber n={4} />
    </Slide>
  ),

  // 5 — Session Agenda
  () => {
    const items = [
      { time: "5 min", title: '"Meet the Project"', desc: "Ask Claude to explain the app. See instant product understanding." },
      { time: "15 min", title: '"User Story to Code"', desc: "Paste a user story. Watch it become working SwiftUI code." },
      { time: "8 min", title: '"Iterate Like a PM"', desc: "Give feedback in plain English. See instant changes." },
      { time: "5 min", title: '"Ship It"', desc: "Commit and push. From idea to pull request in one session." },
    ];
    return (
      <Slide background={bg.dark} align="left">
        <Tag variant="brand">Run of Show</Tag>
        <SectionTitle>What you're about to see</SectionTitle>
        <div style={{ display: "flex", flexDirection: "column", marginTop: 40, width: "100%", maxWidth: 780 }}>
          {items.map((item, i) => (
            <div
              key={i}
              style={{
                display: "flex",
                alignItems: "flex-start",
                gap: 20,
                padding: "20px 0",
                borderLeft: "2px solid rgba(255,255,255,0.15)",
                paddingLeft: 28,
                position: "relative",
              }}
            >
              <div
                style={{
                  position: "absolute",
                  left: -7,
                  top: 26,
                  width: 12,
                  height: 12,
                  borderRadius: "50%",
                  background: colors.brand,
                  border: "2px solid rgba(255,255,255,0.3)",
                }}
              />
              <div
                style={{
                  fontFamily: fonts.mono,
                  fontSize: 14,
                  fontWeight: 600,
                  color: colors.brand,
                  minWidth: 60,
                  background: "rgba(0,105,224,0.15)",
                  padding: "3px 10px",
                  borderRadius: 6,
                }}
              >
                {item.time}
              </div>
              <div>
                <h3 style={{ fontSize: 20, fontWeight: 700, marginBottom: 4 }}>{item.title}</h3>
                <p style={{ fontSize: 15, opacity: 0.65, lineHeight: 1.5 }}>{item.desc}</p>
              </div>
            </div>
          ))}
        </div>
        <SlideNumber n={5} />
      </Slide>
    );
  },

  // 6 — Live Demo: Meet the Project
  () => (
    <Slide background={bg.dark}>
      <Tag variant="green">Live Demo · Part 1</Tag>
      <SectionTitle style={{ textAlign: "center" }}>"Meet the Project"</SectionTitle>
      <CodeBlock style={{ maxWidth: 680, textAlign: "left" }}>
        <Prompt>$</Prompt> claude{"\n\n"}
        <Prompt>{">"}</Prompt> Explain what this app does and who{"\n"}
        {"  "}it's for, in simple terms.
        <Cursor />
      </CodeBlock>
      <TalkingPoint style={{ maxWidth: 680 }}>
        "I start every session like this. Claude reads our project context and understands the product
        instantly. No onboarding, no context-switching."
      </TalkingPoint>
      <SlideNumber n={6} />
    </Slide>
  ),

  // 7 — Live Demo: User Story
  () => (
    <Slide background={bg.dark} align="left">
      <Tag variant="accent">Live Demo · Part 2 — THE MAIN EVENT</Tag>
      <SectionTitle>From user story to code</SectionTitle>
      <CodeBlock style={{ fontSize: 14 }}>
        <Prompt>{">"}</Prompt> As a new user opening REPortfolio for the first{"\n"}
        {"  "}time, I want to see a welcoming empty state that{"\n"}
        {"  "}highlights the app's 3 key benefits — track{"\n"}
        {"  "}property value, compare returns with Gold/Nifty,{"\n"}
        {"  "}and monitor rental income — so I feel confident{"\n"}
        {"  "}adding my first property.{"\n\n"}
        {"  "}Enhance the empty state in PortfolioSummaryView.{"\n"}
        {"  "}Add 3 benefit cards with icons above the "Add{"\n"}
        {"  "}Property" button. Use our design tokens.
        <Cursor />
      </CodeBlock>
      <TalkingPoint>
        "Notice — I described the feature in product language, not code. I didn't say which file,
        which line, or which function. Claude figured that out."
      </TalkingPoint>
      <SlideNumber n={7} />
    </Slide>
  ),

  // 8 — What Claude Does
  () => {
    const steps = [
      { n: 1, bold: "Finding the right file", rest: " — locates the empty state in PortfolioSummaryView.swift" },
      { n: 2, bold: "Reading the design system", rest: " — picks up color tokens, spacing, typography from DesignSystem/" },
      { n: 3, bold: "Matching existing patterns", rest: " — follows the same SwiftUI component style used everywhere else" },
      { n: 4, bold: "Writing the code", rest: " — creates benefit cards with SF Symbol icons, titles, and descriptions" },
    ];
    return (
      <Slide background={bg.dark}>
        <Kicker style={{ opacity: 0.4 }}>Behind the scenes</Kicker>
        <SectionTitle style={{ textAlign: "center" }}>What Claude is doing right now</SectionTitle>
        <ol style={{ listStyle: "none", display: "flex", flexDirection: "column", gap: 18, marginTop: 40, maxWidth: 700, width: "100%" }}>
          {steps.map((s) => (
            <li key={s.n} style={{ fontSize: 20, lineHeight: 1.5, display: "flex", alignItems: "flex-start", gap: 16 }}>
              <span
                style={{
                  minWidth: 36,
                  height: 36,
                  borderRadius: 10,
                  background: "rgba(0,105,224,0.2)",
                  color: "#5BA3EF",
                  fontWeight: 700,
                  fontSize: 16,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  flexShrink: 0,
                }}
              >
                {s.n}
              </span>
              <span>
                <strong>{s.bold}</strong>
                {s.rest}
              </span>
            </li>
          ))}
        </ol>
        <SlideNumber n={8} />
      </Slide>
    );
  },

  // 9 — Iterate
  () => (
    <Slide background={bg.dark} align="left">
      <Tag variant="brand">Live Demo · Part 3</Tag>
      <SectionTitle>Iterate like a PM</SectionTitle>
      <CodeBlock style={{ fontSize: 15 }}>
        <Prompt>{">"}</Prompt> The benefit cards look good. Two tweaks:{"\n"}
        {"  "}1. Change the headline to{"\n"}
        {"     "}"Start Building Your Portfolio"{"\n"}
        {"  "}2. Make the icon circles use our brandPrimary{"\n"}
        {"     "}color with 10% opacity background
        <Cursor />
      </CodeBlock>
      <TalkingPoint>
        "This is the loop I use daily — build, look at it, give feedback, iterate. The conversation
        IS the spec. No tickets, no waiting."
      </TalkingPoint>
      <div style={{ fontSize: 17, opacity: 0.5, marginTop: 24 }}>
        If the audience suggests a change — type it live. Best demo moment.
      </div>
      <SlideNumber n={9} />
    </Slide>
  ),

  // 10 — Ship It
  () => (
    <Slide background={bg.brand}>
      <Kicker>Live Demo · Part 4</Kicker>
      <Title style={{ fontSize: 48 }}>Ship it</Title>
      <CodeBlock
        style={{
          background: "rgba(0,0,0,0.25)",
          borderColor: "rgba(255,255,255,0.15)",
          maxWidth: 500,
          textAlign: "center",
          fontSize: 20,
          marginTop: 32,
        }}
      >
        <Prompt>{">"}</Prompt> /commit
        <Cursor />
      </CodeBlock>
      <Subtitle style={{ marginTop: 28, opacity: 0.85, fontSize: 20 }}>
        Claude writes the commit message from the changes it made.
        <br />
        From user story to committed code. One session.
      </Subtitle>
      <SlideNumber n={10} />
    </Slide>
  ),

  // 11 — Key Takeaways
  () => (
    <Slide background={bg.dark} align="left">
      <Tag variant="green">Takeaways</Tag>
      <SectionTitle>What this means for product</SectionTitle>
      <div style={{ display: "flex", gap: 24, marginTop: 32, width: "100%", maxWidth: 1000 }}>
        <Card
          icon={"\u{1F4AC}"}
          iconBg="transparent"
          iconColor="white"
          title={<>Product language in,<br />code out</>}
          desc={<>Describe the <em>what</em>. Claude handles the <em>how</em>. No translation layer needed.</>}
        />
        <Card
          icon={"\u26A1"}
          iconBg="transparent"
          iconColor="white"
          title={<>Instant<br />iteration</>}
          desc="Feedback loop is conversational, not asynchronous. Seconds, not sprints."
        />
        <Card
          icon={"\u{1F9E0}"}
          iconBg="transparent"
          iconColor="white"
          title={<>Context-<br />aware</>}
          desc="Reads your design system, follows patterns, understands the product."
        />
      </div>
      <SlideNumber n={11} />
    </Slide>
  ),

  // 12 — Q&A
  () => {
    const faqs = [
      {
        q: '"Does it always get it right?"',
        a: "Not always on the first try — just like any engineer. But iteration is so fast that a round-trip taking hours now takes seconds.",
      },
      {
        q: '"Can it work from Figma?"',
        a: "Not directly from Figma files yet, but you can paste design specs or describe visual requirements and it matches your design system.",
      },
      {
        q: '"What about complex logic?"',
        a: "It handles that too — our valuation caching, investment math, all built with Claude. The key is good context via CLAUDE.md.",
      },
      {
        q: '"Is it replacing engineers?"',
        a: "No — it's making engineers faster. You still make all the product and architecture decisions. Claude handles the boilerplate.",
      },
    ];
    return (
      <Slide background={bg.dark}>
        <SectionTitle style={{ textAlign: "center", marginBottom: 8 }}>Questions?</SectionTitle>
        <div style={{ fontSize: 20, textAlign: "center", opacity: 0.45, marginBottom: 12 }}>
          Some answers you might need
        </div>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr",
            gap: 20,
            marginTop: 36,
            maxWidth: 900,
            width: "100%",
          }}
        >
          {faqs.map((f, i) => (
            <div
              key={i}
              style={{
                background: "rgba(255,255,255,0.06)",
                border: "1px solid rgba(255,255,255,0.08)",
                borderRadius: 14,
                padding: 24,
              }}
            >
              <div style={{ fontSize: 16, fontWeight: 700, marginBottom: 10, color: "#5BA3EF" }}>
                {f.q}
              </div>
              <div style={{ fontSize: 15, lineHeight: 1.6, opacity: 0.75 }}>{f.a}</div>
            </div>
          ))}
        </div>
        <SlideNumber n={12} />
      </Slide>
    );
  },
];

// ─── Main Deck Component ───
export default function DemoSlides() {
  const [current, setCurrent] = useState(0);
  const total = slides.length;

  const goTo = useCallback(
    (n) => {
      if (n >= 0 && n < total) setCurrent(n);
    },
    [total]
  );

  useEffect(() => {
    const handler = (e) => {
      if (e.key === "ArrowRight" || e.key === " ") {
        e.preventDefault();
        goTo(current + 1);
      }
      if (e.key === "ArrowLeft") {
        e.preventDefault();
        goTo(current - 1);
      }
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [current, goTo]);

  const CurrentSlide = slides[current];

  return (
    <>
      {/* Inject keyframe for blinking cursor */}
      <style>{`@keyframes blink { 50% { opacity: 0; } }`}</style>

      <div style={{ width: "100vw", height: "100vh", overflow: "hidden", background: "#0D1117", fontFamily: fonts.sans }}>
        {/* Slide */}
        <div style={{ width: "100%", height: "calc(100% - 56px)" }}>
          <CurrentSlide />
        </div>

        {/* Nav Bar */}
        <div
          style={{
            height: 56,
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            padding: "0 32px",
            background: "rgba(13,17,23,0.85)",
            backdropFilter: "blur(12px)",
            borderTop: "1px solid rgba(255,255,255,0.06)",
          }}
        >
          <button onClick={() => goTo(current - 1)} style={navBtnStyle}>
            {"\u2190"} Prev
          </button>

          {/* Progress dots */}
          <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
            {slides.map((_, i) => (
              <div
                key={i}
                onClick={() => goTo(i)}
                style={{
                  width: i === current ? 24 : 8,
                  height: 8,
                  borderRadius: i === current ? 4 : "50%",
                  background:
                    i === current
                      ? colors.brand
                      : i < current
                      ? "rgba(0,105,224,0.5)"
                      : "rgba(255,255,255,0.15)",
                  cursor: "pointer",
                  transition: "all 0.3s ease",
                }}
              />
            ))}
          </div>

          <span style={{ fontSize: 12, color: "rgba(255,255,255,0.3)", fontFamily: fonts.mono }}>
            Arrow keys or click
          </span>

          <button onClick={() => goTo(current + 1)} style={navBtnStyle}>
            Next {"\u2192"}
          </button>
        </div>
      </div>
    </>
  );
}

const navBtnStyle = {
  background: "rgba(255,255,255,0.08)",
  border: "1px solid rgba(255,255,255,0.12)",
  color: "white",
  fontFamily: fonts.sans,
  fontSize: 13,
  fontWeight: 600,
  padding: "8px 20px",
  borderRadius: 8,
  cursor: "pointer",
  display: "flex",
  alignItems: "center",
  gap: 6,
};
