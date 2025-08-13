-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.chatbot_settings (
  title text NOT NULL,
  chatbots_id uuid NOT NULL,
  suggested_questions ARRAY,
  host_domains ARRAY,
  embedded_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  welcome_message text NOT NULL DEFAULT 'Hello there! 👋 How can I assist you today? Feel free to ask anything!'::text,
  input_placeholder text NOT NULL DEFAULT 'Ask me anything'::text,
  powered_by jsonb NOT NULL DEFAULT '{"url": "https://webagent.ai/", "name": "WebAgent.ai"}'::jsonb,
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
CREATE TABLE public.chatbots (
  voice_prompt text,
  name text NOT NULL,
  domains ARRAY,
  prompt text,
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  status text NOT NULL DEFAULT 'Draft'::text,
  created_at timestamp with time zone DEFAULT now(),
  logo_url text DEFAULT ''::text,
  temperature real NOT NULL DEFAULT '0.1'::real,
  model USER-DEFINED NOT NULL DEFAULT 'gpt-4o'::model_types,
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
CREATE TABLE public.conversations (
  chatbot_id uuid,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  preview_message text,
  contact_id bigint,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  closed boolean NOT NULL DEFAULT false,
  is_archived boolean NOT NULL DEFAULT false,
  CONSTRAINT conversations_pkey PRIMARY KEY (id),
  CONSTRAINT conversations_chatbot_id_fkey FOREIGN KEY (chatbot_id) REFERENCES public.chatbots(id),
  CONSTRAINT conversations_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.contacts(id)
);
CREATE TABLE public.documents (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  content text,
  metadata jsonb,
  embedding USER-DEFINED,
  vendor_id bigint,
  vendor_name text,
  web_page_id uuid,
  CONSTRAINT documents_pkey PRIMARY KEY (id),
  CONSTRAINT documents_web_page_id_fkey FOREIGN KEY (web_page_id) REFERENCES public.web_pages(id),
  CONSTRAINT documents_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id),
  CONSTRAINT documents_web_pages_id_fkey FOREIGN KEY (web_page_id) REFERENCES public.web_pages(id)
);
CREATE TABLE public.messages (
  content text,
  role text NOT NULL,
  has_knowledge boolean,
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  conversation_id bigint,
  rephrased_message text,
  CONSTRAINT messages_pkey PRIMARY KEY (id),
  CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id)
);
CREATE TABLE public.vendors (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NOT NULL,
  domain text NOT NULL,
  target_selector text,
  teleperson_id bigint UNIQUE,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  remove_selectors ARRAY,
  description text,
  CONSTRAINT vendors_pkey PRIMARY KEY (id)
);
CREATE TABLE public.web_pages (
  url text NOT NULL UNIQUE,
  num_characters integer,
  error_message text,
  description text,
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  title text DEFAULT ''::text,
  vendor_id bigint NOT NULL,
  scheduled_at timestamp with time zone,
  status USER-DEFINED NOT NULL DEFAULT 'Staging'::web_page_status,
  num_attempts integer NOT NULL DEFAULT 0,
  CONSTRAINT web_pages_pkey PRIMARY KEY (id),
  CONSTRAINT web_pages_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id)
);