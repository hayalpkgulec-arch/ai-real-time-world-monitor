# AI Real-Time World Monitor --- Ultimate Build Prompt

You are an elite AI engineer, distributed systems architect, and mobile
developer.

Your goal is to design and build a **production-grade global
intelligence platform** called:

AI Real-Time World Monitor

The system must monitor global events in real time and explain their
economic, geopolitical, and market impact using AI.

The application must include:

• React Native mobile app\
• Scalable backend API\
• Real-time data ingestion system\
• AI event detection engine\
• AI summarization & prediction layer\
• real-time alerts\
• production-level architecture

This document is a **complete blueprint** for the AI system that will
generate the entire product.

------------------------------------------------------------------------

# 1. Product Mission

The platform answers:

"What important events are happening in the world right now and how do
they affect markets and global stability?"

Users receive:

• real-time global alerts\
• AI explanations\
• geopolitical risk indicators\
• market impact predictions\
• daily global intelligence briefings

Target users:

• traders\
• investors\
• journalists\
• analysts\
• entrepreneurs

------------------------------------------------------------------------

# 2. Core Product Modules

## Global Risk Radar

Detect:

wars\
sanctions\
economic crises\
energy disruptions\
political instability\
natural disasters

Example output:

Event: Middle East Escalation\
Risk Level: High\
Confidence: 74%\
Possible Impact: Oil Prices Rising

------------------------------------------------------------------------

## Market Impact Engine

Predict market reactions.

Example:

Event: Military Conflict

Oil: +65% probability increase\
Gold: +40% probability increase\
Stocks: -35% probability decrease

------------------------------------------------------------------------

## Global Trend Detection

Detect emerging global discussions.

Example:

Trend: AI regulation\
Trend Score: 82

Trend: China economic slowdown\
Trend Score: 75

------------------------------------------------------------------------

## AI Global Briefing

Daily AI-generated report summarizing major global events.

Example:

Daily Global Brief

1.  Oil prices surged due to Middle East tensions\
2.  Tech stocks declined after new regulatory proposals\
3.  Bitcoin volatility increased following macroeconomic data

------------------------------------------------------------------------

# 3. Production Architecture (Netflix / Bloomberg Style)

The architecture must support:

• millions of events\
• high ingestion throughput\
• real-time analytics\
• global scale

Architecture:

                Global Data Sources
                        |
                        v
                 Ingestion Layer
            (stream processors)
                        |
                        v
                 Message Queue
                   (Event Bus)
                        |
                        v
               Event Detection Engine
                        |
                        v
                AI Analysis Services
                        |
                        v
                Distributed Databases
                        |
                        v
                    API Gateway
                        |
                        v
               React Native Mobile App

------------------------------------------------------------------------

Key infrastructure components:

API Gateway\
Event streaming system\
Distributed processing workers\
AI inference services\
Caching layer\
Alert notification service

------------------------------------------------------------------------

# 4. AI Event Detection Engine

The event detection engine processes thousands of news signals to detect
meaningful global events.

Pipeline:

News Collection\
↓\
Text Processing\
↓\
Entity Extraction\
↓\
Topic Clustering\
↓\
Event Detection\
↓\
Impact Prediction

------------------------------------------------------------------------

Algorithm Steps

1.  Collect headlines from news feeds

Fields:

title\
source\
timestamp\
content\
region

------------------------------------------------------------------------

2.  NLP Extraction

Extract:

entities\
locations\
topics\
sentiment

Example:

Article: "Oil surges after military escalation"

Extracted:

entity: oil\
event: military escalation\
region: middle east

------------------------------------------------------------------------

3.  Topic Clustering

Group similar stories.

Methods:

cosine similarity\
embedding search\
clustering

Detected cluster example:

Multiple articles discussing:

"shipping disruptions"

Event:

Global Shipping Risk

------------------------------------------------------------------------

4.  Event Importance Scoring

Score formula:

EventScore = (article_count × 0.4) + (source_credibility × 0.3) +
(trend_velocity × 0.3)

Events above threshold trigger alerts.

------------------------------------------------------------------------

5.  Market Impact Prediction

Based on historical correlations.

Example:

Event: Military Conflict

Oil ↑\
Gold ↑\
Stocks ↓

------------------------------------------------------------------------

# 5. Open Source AI Models

The system should support open-source AI models.

Recommended models:

DeepSeek Coder\
LLaMA\
Mistral\
Qwen

Use cases:

summarization\
entity extraction\
classification\
event clustering

Local inference preferred to reduce cost.

------------------------------------------------------------------------

# 6. Global Data Sources

## News Sources

Global RSS feeds

Examples categories:

world news\
politics\
economics\
energy\
technology

Sources:

international newspapers\
global news agencies\
financial media

------------------------------------------------------------------------

## Financial Data

Collect:

oil price\
gold price\
stock indices\
crypto prices

Sources:

public market APIs\
crypto exchanges\
financial data aggregators

------------------------------------------------------------------------

## Geopolitical Data

Sources include:

government announcements\
military activity reports\
international organizations\
economic data releases

Data types:

sanctions\
conflicts\
trade restrictions\
policy changes

------------------------------------------------------------------------

# 7. Zero-Cost Data Pipeline

Early stage must operate with **no infrastructure cost**.

Strategy:

Use free data sources.

Use scheduled jobs to fetch RSS feeds.

Pipeline:

RSS feeds\
↓\
Parser scripts\
↓\
Database storage\
↓\
Event detection\
↓\
API responses

Use lightweight services for early deployment.

------------------------------------------------------------------------

# 8. Backend API Design

Endpoints:

GET /events

Returns latest global events

------------------------------------------------------------------------

GET /trends

Returns trending global topics

------------------------------------------------------------------------

GET /markets

Returns current market indicators

------------------------------------------------------------------------

GET /alerts

Returns urgent global alerts

------------------------------------------------------------------------

GET /daily-brief

Returns AI-generated daily briefing

------------------------------------------------------------------------

# 9. Mobile Application (React Native)

Main screens:

Home Dashboard

Displays:

oil price\
gold price\
bitcoin price\
risk index\
latest events

------------------------------------------------------------------------

Global Map

Interactive map displaying:

conflict zones\
economic risks\
event clusters

------------------------------------------------------------------------

Event Feed

Timeline of events with:

AI summary\
risk level\
predicted market impact

------------------------------------------------------------------------

Alerts

Push notifications for major events.

------------------------------------------------------------------------

Daily Brief

AI global intelligence report.

------------------------------------------------------------------------

# 10. UI Design Principles

Minimal\
data-focused\
fast\
high information density

Color system:

Green = positive market signal\
Red = crisis\
Yellow = warning

------------------------------------------------------------------------

# 11. Viral Growth Strategy

The product must grow organically through shareable insights.

Key strategy:

Daily World Brief

Users receive a daily summary they can share.

Example:

GLOBAL BRIEF

3 key events today

1.  Oil surged due to geopolitical tensions\
2.  China growth concerns increased\
3.  Bitcoin volatility spiked

Users can share the report on social platforms.

------------------------------------------------------------------------

Growth tactics:

shareable event cards\
viral charts\
daily global briefing posts\
community discussion features

------------------------------------------------------------------------

# 12. MVP Scope

Minimum version:

Mobile App

dashboard\
event feed\
daily briefing

Backend

RSS ingestion\
event detection\
AI summaries

------------------------------------------------------------------------

# 13. Development Phases

Phase 1

data ingestion system\
backend API

Phase 2

event detection algorithm

Phase 3

React Native mobile app

Phase 4

alerts and trend detection

Phase 5

AI impact prediction

------------------------------------------------------------------------

# 14. Deliverables

The system must generate:

complete backend code\
React Native mobile app\
database schema\
API documentation\
deployment instructions

------------------------------------------------------------------------

# Final Instruction

Build the system step by step starting with:

1 backend architecture\
2 database schema\
3 data pipeline\
4 event detection engine\
5 AI analysis layer\
6 mobile application
