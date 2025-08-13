# Jessica Dev by Mangesh - Complete Architecture Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture Flow Diagram](#architecture-flow-diagram)
3. [Technology Stack](#technology-stack)
4. [Environment Setup](#environment-setup)
5. [Key Features](#key-features)
6. [Voice Capabilities](#voice-capabilities)
7. [Deployment Guide](#deployment-guide)
8. [Troubleshooting](#troubleshooting)

---

## Project Overview

**Jessica Dev by Mangesh** is an AI-Powered Vendor Management Assistant - a sophisticated chatbot built with Next.js. The system helps users navigate and get information about vendors through intelligent conversational AI with both text and voice capabilities.

### Core Functionality
- **Vendor-specific assistance** using RAG (Retrieval Augmented Generation)
- **Real-time voice chat** via Vapi AI integration
- **Semantic knowledge search** with vector embeddings
- **Multi-modal conversations** (text + voice simultaneously)
- **Comprehensive observability** via Langfuse
- **Embeddable widget** for any website

---

## Architecture Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                           USER INTERACTION                         │
└─────────────────┬───────────────────────────────────┬─────────────────┘
                  │                                   │
            ┌─────▼─────┐                       ┌─────▼─────┐
            │   TEXT    │                       │   VOICE   │
            │   CHAT    │                       │   CHAT    │
            │ (Browser) │                       │  (Vapi)   │
            └─────┬─────┘                       └─────┬─────┘
                  │                                   │
                  └─────────────┬───────────────────┘
                                │
                          ┌─────▼─────┐
                          │  Next.js  │
                          │  Frontend │
                          │ (React)   │
                          └─────┬─────┘
                                │
         ┌──────────────────────┼──────────────────────┐
         │                      │                      │
   ┌─────▼─────┐          ┌─────▼─────┐          ┌─────▼─────┐
   │ ChatWidget│          │   Chat    │          │   Voice   │
   │Components │          │ Context   │          │Integration│
   │           │          │ Provider  │          │  (Vapi)   │
   └───────────┘          └─────┬─────┘          └───────────┘
                                │
                    ┌───────────▼───────────┐
                    │    API Routes         │
                    │  /api/chat/route.js   │
                    └─────────┬─────────────┘
                              │
                    ┌─────────▼─────────┐
                    │  Request Processing│
                    │  • Rate Limiting   │
                    │  • User Context    │
                    │  • Message History │
                    └─────────┬─────────┘
                              │
┌─────────────────────────────▼──────────────────────────────┐
│                    AI PROCESSING PIPELINE                  │
├─────────────────┬──────────────────┬─────────────────────┤
│                 │                  │                     │
│  ┌──────────────▼──────────────┐   │   ┌─────────────────▼─────────────────┐
│  │      Langfuse Integration   │   │   │         Model Selection            │
│  │  • Fetch dynamic prompt     │   │   │  Primary: OpenAI GPT-4o-mini      │
│  │  • Compile with user vars   │   │   │  Secondary: Google Gemini Flash    │
│  │  • Track performance        │   │   │  Voice: GPT-4o via Vapi           │
│  └──────────────┬──────────────┘   │   └─────────────────┬─────────────────┘
│                 │                  │                     │
│                 └──────────────────┼─────────────────────┘
│                                    │
│                ┌───────────────────▼────────────────────┐
│                │           Tool Decision                │
│                │    Does user query need tools?        │
│                └───────────┬────────────────────────────┘
│                            │
│            ┌───────────────▼────────────────┐
│            │          Tool Execution        │
│            └───────────┬────────────────────┘
│                        │
└────────────────────────┼─────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────┐
│                KNOWLEDGE RETRIEVAL                       │
├─────────────────┬──────────────────┬─────────────────────┤
│                 │                  │                     │
│  ┌──────────────▼──────────────┐   │   ┌─────────────────▼─────────────────┐
│  │     getInformation Tool     │   │   │      Vector Search Process        │
│  │  • Question analysis        │   │   │  1. Generate embeddings           │
│  │  • Vendor name extraction   │   │   │  2. Semantic similarity search    │
│  │  • Knowledge base query     │   │   │  3. Filter by vendor              │
│  └──────────────┬──────────────┘   │   │  4. Rank by relevance             │
│                 │                  │   │  5. Deduplicate sources           │
│                 │                  │   └─────────────────┬─────────────────┘
│                 │                  │                     │
│                 └──────────────────┼─────────────────────┘
│                                    │
│                ┌───────────────────▼────────────────────┐
│                │        Supabase Database              │
│                │  • Vector embeddings store           │
│                │  • match_documents_by_vendor_name()   │
│                │  • Similarity threshold: 0.83        │
│                │  • Return top 8 matches              │
│                └───────────────────┬────────────────────┘
│                                    │
│                ┌───────────────────▼────────────────────┐
│                │     Content Extraction                │
│                │  • Google Gemini processes raw docs   │
│                │  • Extracts relevant information      │
│                │  • Returns structured response        │
│                └───────────────────┬────────────────────┘
└────────────────────────────────────┼─────────────────────┘
                                     │
┌────────────────────────────────────▼─────────────────────┐
│                 RESPONSE GENERATION                      │
├─────────────────┬──────────────────┬─────────────────────┤
│                 │                  │                     │
│  ┌──────────────▼──────────────┐   │   ┌─────────────────▼─────────────────┐
│  │    Stream Text Generation   │   │   │        Response Assembly          │
│  │  • Real-time streaming      │   │   │  • Combine context + knowledge    │
│  │  • Smooth typing effect     │   │   │  • Add source citations          │
│  │  • Token limits: 1500       │   │   │  • Format for user display       │
│  │  • Temperature: 0.2         │   │   │  • Include metadata              │
│  └──────────────┬──────────────┘   │   └─────────────────┬─────────────────┘
│                 │                  │                     │
│                 └──────────────────┼─────────────────────┘
│                                    │
└────────────────────────────────────┼─────────────────────┘
                                     │
┌────────────────────────────────────▼─────────────────────┐
│                  DATA PERSISTENCE                        │
├─────────────────┬──────────────────┬─────────────────────┤
│                 │                  │                     │
│  ┌──────────────▼──────────────┐   │   ┌─────────────────▼─────────────────┐
│  │     Conversation Storage    │   │   │        Analytics Tracking         │
│  │  • New conversation ID      │   │   │  • Message count               │
│  │  • User contact upsert      │   │   │  • Response time               │
│  │  • Message history save     │   │   │  • Tool usage stats           │
│  │  • Source attributions      │   │   │  • Cost tracking               │
│  └──────────────┬──────────────┘   │   │  • Error monitoring            │
│                 │                  │   └─────────────────┬─────────────────┘
│                 │                  │                     │
│                 └──────────────────┼─────────────────────┘
│                                    │
│                ┌───────────────────▼────────────────────┐
│                │         Supabase Database             │
│                │  • conversations table                │
│                │  • messages table                     │
│                │  • contacts table                     │
│                │  • chatbot_settings table            │
│                └───────────────────┬────────────────────┘
└────────────────────────────────────┼─────────────────────┘
                                     │
┌────────────────────────────────────▼─────────────────────┐
│                 MONITORING & OBSERVABILITY               │
├─────────────────┬──────────────────┬─────────────────────┤
│                 │                  │                     │
│  ┌──────────────▼──────────────┐   │   ┌─────────────────▼─────────────────┐
│  │      Langfuse Traces        │   │   │        Error Handling             │
│  │  • Full conversation flow   │   │   │  • Slack notifications            │
│  │  • Performance metrics      │   │   │  • Sentry error tracking         │
│  │  • Cost attribution         │   │   │  • Fallback responses            │
│  │  • Quality scoring          │   │   │  • Graceful degradation          │
│  └──────────────┬──────────────┘   │   └─────────────────┬─────────────────┘
│                 │                  │                     │
│                 └──────────────────┼─────────────────────┘
│                                    │
│                ┌───────────────────▼────────────────────┐
│                │      OpenTelemetry Integration        │
│                │  • Service-wide tracing               │
│                │  • Performance monitoring             │
│                │  • Custom metrics collection          │
│                └────────────────────────────────────────┘
└──────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Frontend Framework
- **Next.js 15.2.4** with React 19.0.0
- **Tailwind CSS 4** for styling
- **Radix UI** components for accessible UI elements
- **Framer Motion** for animations

### AI & Chat Infrastructure
- **OpenAI GPT-4o-mini** as primary model
- **Google Gemini 2.0 Flash** for content extraction
- **AI SDK** for streaming chat responses
- **Langfuse** for prompt management and observability
- **Vector embeddings** using Supabase's `gte-small` model

### Backend & Database
- **Supabase** as primary database and backend service
- **PostgreSQL** with vector similarity search
- **Redis** (Upstash) for rate limiting
- **Vercel** deployment platform

### Voice Integration
- **Vapi AI** (`@vapi-ai/web`) for voice conversations
- **ElevenLabs** voice synthesis
- **React Siri Wave** for voice visualizations

### Monitoring & Analytics
- **Sentry** for error tracking
- **Langfuse** for AI observability
- **OpenTelemetry** for performance monitoring

### Vercel SDK Components
- **@vercel/functions** - Serverless functions runtime
- **@vercel/mcp-adapter** - Model Context Protocol adapter
- **@vercel/otel** - OpenTelemetry integration

---

## Environment Setup

### Prerequisites
- **Node.js** 18+ (recommended: latest LTS)
- **npm** or **yarn** package manager
- **Git** for version control

### Required Environment Variables

Create a `.env.local` file in the project root:

```bash
# Core Database (Required)
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
SUPABASE_SERVICE_KEY=your_supabase_service_role_key

# AI Services (Required)
OPENAI_API_KEY=sk-your_openai_api_key
GOOGLE_AI_API_KEY=your_google_ai_api_key

# Observability & Monitoring (Required)
LANGFUSE_PUBLIC_KEY=pk-your_langfuse_public_key
LANGFUSE_SECRET_KEY=sk-your_langfuse_secret_key
LANGFUSE_BASEURL=https://cloud.langfuse.com

# Voice Features (Optional)
NEXT_PUBLIC_VAPI_PUBLIC_KEY=your_vapi_public_key

# Rate Limiting (Optional)
UPSTASH_REDIS_URL=your_upstash_redis_url
UPSTASH_REDIS_TOKEN=your_upstash_redis_token

# External Integrations (Optional)
MCP_SERVER_DOMAIN=https://your-mcp-server.com
SLACK_WEBHOOK_URL=your_slack_webhook_url

# Development/Production URLs
NEXT_PUBLIC_APP_URL=http://localhost:3000  # dev
# NEXT_PUBLIC_APP_URL=https://your-domain.com  # production
```

### Installation Steps

1. **Install Dependencies**
```bash
cd jessica-chatbot-npe
npm install
```

2. **Database Setup (Supabase)**
   - Create Supabase project
   - Enable vector extension
   - Set up required tables:
     - `chatbot_settings` - Chatbot configuration
     - `conversations` - Chat sessions
     - `messages` - Individual chat messages
     - `contacts` - User information
     - `documents` - Knowledge base with vector embeddings

3. **Langfuse Setup**
   - Create account at langfuse.com
   - Create project and get API keys
   - **Important**: Create a prompt named `"vendor-chatbot-text"`

4. **Run Development Server**
```bash
# With Turbopack (recommended)
npm run dev

# Standard Next.js
npm run devv
```

---

## Key Features

### Intelligent Conversation Flow

1. **User Input Processing**
   - Rate limiting and validation
   - Context loading (user info, vendor list, chat history)
   - Multi-modal support (text/voice)

2. **AI Processing Pipeline**
   - Dynamic prompt compilation via Langfuse
   - Multi-step reasoning (up to 5 tool calls)
   - Model selection based on task

3. **Knowledge Retrieval**
   - Semantic search using vector embeddings
   - Vendor-specific filtering
   - Content extraction and summarization

4. **Response Generation**
   - Real-time streaming responses
   - Source citations and metadata
   - Smooth typing effects

### Embed Script System

The chatbot generates a complete JavaScript embed script accessible via:
```
GET /api/chatbot
```

**Features:**
- Single-line integration: `<script src="your-domain.com/api/chatbot" async></script>`
- Floating chat bubble with customizable appearance
- Welcome message popups
- Responsive design (mobile/desktop)
- Microphone permissions for voice features
- Cross-origin messaging for parent-iframe communication

---

## Voice Capabilities

### Technology Stack
- **Vapi AI** for real-time voice processing
- **ElevenLabs** for voice synthesis (Voice ID: `g6xIsTj2HwM6VR4iXFCw`)
- **GPT-4o** for voice-optimized responses

### Voice Features
- ✅ **Real-time speech recognition**
- ✅ **Natural conversation flow**
- ✅ **Interruption handling** with smart phrases
- ✅ **Voice activity visualization**
- ✅ **Seamless text-to-voice switching**
- ✅ **Same knowledge base** as text chat
- ✅ **Conversation persistence** across modes

### Voice Configuration
```javascript
// Smart interruption handling
stopSpeakingPlan: {
    numWords: 3,
    voiceSeconds: 0.2,
    acknowledgementPhrases: ["okay", "right", "got it"],
    interruptionPhrases: ["stop", "actually", "but"]
}

// Call limits
silenceTimeoutSeconds: 30,
maxDurationSeconds: 300
```

---

## Deployment Guide

### Vercel Deployment (Recommended)
1. Connect repository to Vercel
2. Set environment variables in Vercel dashboard
3. Deploy automatically on git push

### Platform Considerations
- **Vercel**: Full feature support (geolocation, telemetry)
- **Other platforms**: Core functionality works, may lose some Vercel-specific features

### Domain Configuration
Update these settings for custom domains:
1. Change iframe URL in `generateScript.js`
2. Update CORS origins in API routes
3. Set `NEXT_PUBLIC_APP_URL` environment variable
4. Configure allowed domains in Supabase settings

---

## Troubleshooting

### Common Issues

**Database Connection Errors**
- Verify Supabase URL and service key
- Check if required tables exist
- Ensure vector extension is enabled

**AI Service Errors**
- Confirm API keys are valid and have credits
- Check Langfuse prompt exists (`vendor-chatbot-text`)
- Monitor rate limits on AI services

**Voice Features Not Working**
- Ensure `NEXT_PUBLIC_VAPI_PUBLIC_KEY` is set
- Check browser microphone permissions
- Verify HTTPS in production (required for microphone access)

**Embed Script Issues**
- Verify iframe permissions and CORS settings
- Check domain allowlist in chatbot settings
- Ensure proper origin validation

### Performance Optimization

**Response Speed**
- Monitor Langfuse traces for bottlenecks
- Optimize knowledge base queries
- Adjust embedding similarity thresholds

**Cost Management**
- Track token usage via Langfuse
- Implement conversation limits
- Monitor API spend across services

**Error Handling**
- Set up Slack notifications for critical errors
- Configure Sentry for frontend error tracking
- Implement graceful fallbacks for AI failures

---

## Development Notes

### File Structure
- `app/` - Next.js 15 app router pages and API routes
- `components/` - React UI components and chat widgets
- `context/` - React context providers for chat state
- `lib/` - Utility functions and service integrations
- `public/` - Static assets

### Key API Routes
- `/api/chat` - Main chat processing endpoint
- `/api/chatbot` - Embed script generation
- `/api/geo` - Geolocation services (Vercel-specific)

### Chat Context Providers
- `ChatContext.jsx` - Authenticated user chat
- `ChatContext.sales.jsx` - Public/sales chat
- `ChatContext.demo.jsx` - Demo environment

This architecture provides a production-ready, scalable AI chatbot with comprehensive monitoring, multi-modal interaction, and enterprise-grade observability.
