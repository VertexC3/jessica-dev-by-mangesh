-- Jessica Chatbot NPE - Database Setup Script
-- This script sets up all required tables and custom types for development

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;

-- Create custom types
CREATE TYPE model_types AS ENUM ('gpt-3.5-turbo', 'gpt-4', 'gpt-4o', 'gpt-4o-mini');
CREATE TYPE web_page_status AS ENUM ('Staging', 'Processing', 'Completed', 'Failed');

-- Create tables in dependency order

-- 1. Independent tables first
CREATE TABLE public.chatbots (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  voice_prompt text,
  name text NOT NULL,
  domains text[],
  prompt text,
  status text NOT NULL DEFAULT 'Draft'::text,
  created_at timestamp with time zone DEFAULT now(),
  logo_url text DEFAULT ''::text,
  temperature real NOT NULL DEFAULT '0.1'::real,
  model model_types NOT NULL DEFAULT 'gpt-4o'::model_types,
  CONSTRAINT chatbots_pkey PRIMARY KEY (id)
);

CREATE TABLE public.contacts (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  first_name text,
  last_name text,
  email text NOT NULL DEFAULT ''::text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  teleperson_id bigint NOT NULL UNIQUE,
  CONSTRAINT contacts_pkey PRIMARY KEY (id)
);

CREATE TABLE public.vendors (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NOT NULL,
  domain text NOT NULL,
  target_selector text,
  teleperson_id bigint UNIQUE,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  remove_selectors text[],
  description text,
  CONSTRAINT vendors_pkey PRIMARY KEY (id)
);

-- 2. Tables with dependencies
CREATE TABLE public.chatbot_settings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  chatbots_id uuid NOT NULL,
  suggested_questions text[],
  host_domains text[],
  embedded_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  welcome_message text NOT NULL DEFAULT 'Hello there! 👋 How can I assist you today? Feel free to ask anything!'::text,
  input_placeholder text NOT NULL DEFAULT 'Ask me anything'::text,
  powered_by jsonb NOT NULL DEFAULT '{"url": "https://teleperson.com/", "name": "Teleperson"}'::jsonb,
  logo_url text DEFAULT ''::text,
  accent_color text DEFAULT '#653aff'::text,
  text_color text DEFAULT '#ffffff'::text,
  subheading text DEFAULT ''::text,
  is_dark boolean NOT NULL DEFAULT false,
  show_popup boolean NOT NULL DEFAULT true,
  disclaimer jsonb NOT NULL DEFAULT '{"title": "", "display": false, "description": ""}'::jsonb,
  CONSTRAINT chatbot_settings_pkey PRIMARY KEY (id),
  CONSTRAINT chatbot_settings_chatbots_id_fkey FOREIGN KEY (chatbots_id) REFERENCES public.chatbots(id)
);

CREATE TABLE public.conversations (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  chatbot_id uuid,
  preview_message text,
  contact_id bigint,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  closed boolean NOT NULL DEFAULT false,
  is_archived boolean NOT NULL DEFAULT false,
  CONSTRAINT conversations_pkey PRIMARY KEY (id),
  CONSTRAINT conversations_chatbot_id_fkey FOREIGN KEY (chatbot_id) REFERENCES public.chatbots(id),
  CONSTRAINT conversations_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.contacts(id)
);

CREATE TABLE public.web_pages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  url text NOT NULL UNIQUE,
  num_characters integer,
  error_message text,
  description text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  title text DEFAULT ''::text,
  vendor_id bigint NOT NULL,
  scheduled_at timestamp with time zone,
  status web_page_status NOT NULL DEFAULT 'Staging'::web_page_status,
  num_attempts integer NOT NULL DEFAULT 0,
  CONSTRAINT web_pages_pkey PRIMARY KEY (id),
  CONSTRAINT web_pages_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id)
);

CREATE TABLE public.messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  content text,
  role text NOT NULL,
  has_knowledge boolean,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  conversation_id bigint,
  rephrased_message text,
  CONSTRAINT messages_pkey PRIMARY KEY (id),
  CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id)
);

CREATE TABLE public.documents (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  content text,
  metadata jsonb,
  embedding vector(1536),  -- OpenAI embeddings dimension
  vendor_id bigint,
  vendor_name text,
  web_page_id uuid,
  CONSTRAINT documents_pkey PRIMARY KEY (id),
  CONSTRAINT documents_web_page_id_fkey FOREIGN KEY (web_page_id) REFERENCES public.web_pages(id),
  CONSTRAINT documents_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id)
);

-- Create indexes for performance
CREATE INDEX idx_documents_embedding ON public.documents USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX idx_documents_vendor_name ON public.documents (vendor_name);
CREATE INDEX idx_messages_conversation_id ON public.messages (conversation_id);
CREATE INDEX idx_conversations_chatbot_id ON public.conversations (chatbot_id);
CREATE INDEX idx_web_pages_vendor_id ON public.web_pages (vendor_id);

-- Create RPC function for vector similarity search
CREATE OR REPLACE FUNCTION match_documents_by_vendor_name(
  query_embedding vector(1536),
  match_threshold float,
  match_count int,
  vendor_name_param text
)
RETURNS TABLE (
  id bigint,
  content text,
  metadata jsonb,
  vendor_name text,
  similarity float
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    documents.id,
    documents.content,
    documents.metadata,
    documents.vendor_name,
    1 - (documents.embedding <=> query_embedding) AS similarity
  FROM documents
  WHERE documents.vendor_name = vendor_name_param
    AND 1 - (documents.embedding <=> query_embedding) > match_threshold
  ORDER BY documents.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Create RPC function for incrementing messages sent (if needed later)
CREATE OR REPLACE FUNCTION increment_messages_sent(
  team_id uuid,
  increment_value int,
  created_at timestamp with time zone
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  -- This is a placeholder function
  -- Implement team-based message counting if needed
  RAISE NOTICE 'increment_messages_sent called with team_id: %, increment: %', team_id, increment_value;
END;
$$;

-- Insert sample data for testing
DO $$
DECLARE
  sample_chatbot_id uuid;
  sample_vendor_id bigint;
BEGIN
  -- Insert sample chatbot
  INSERT INTO public.chatbots (id, name, prompt, status)
  VALUES ('fb0b48ba-9449-4e83-bc51-43e2651e3e16', 'Teleperson Concierge', 'You are a helpful AI assistant for vendor management.', 'Active')
  RETURNING id INTO sample_chatbot_id;

  -- Insert sample chatbot settings
  INSERT INTO public.chatbot_settings (
    chatbots_id, 
    title,
    welcome_message,
    suggested_questions
  ) VALUES (
    sample_chatbot_id,
    'Teleperson Concierge',
    'Hello! I''m your Teleperson Concierge. How can I help you with your vendors today?',
    ARRAY['What vendors do I have?', 'How can I contact support?', 'Tell me about my account']
  );

  -- Insert sample vendor
  INSERT INTO public.vendors (name, domain, description)
  VALUES ('Sample Vendor', 'example.com', 'A sample vendor for testing purposes')
  RETURNING id INTO sample_vendor_id;

  RAISE NOTICE 'Sample data inserted successfully. Chatbot ID: %', sample_chatbot_id;
END $$;
