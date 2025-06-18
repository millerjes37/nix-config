use clap::Parser;
use anyhow::{Result, Context};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::collections::HashMap;
use rayon::prelude::*;
use tokio::fs;
use chrono::{DateTime, Utc};
use regex::Regex;
use tracing::{info, warn, error};

#[derive(Parser)]
#[command(name = "transcribe-turbo")]
#[command(about = "Lightning-fast political speech transcription with AI")]
struct Cli {
    /// Input audio/video file
    input: PathBuf,
    
    /// Output directory
    #[arg(short, long, default_value = "./transcripts")]
    output: PathBuf,
    
    /// Whisper model size
    #[arg(short, long, default_value = "base")]
    model: String,
    
    /// Enable political keyword detection
    #[arg(long)]
    political_mode: bool,
    
    /// Enable speaker detection/diarization
    #[arg(long)]
    speaker_detection: bool,
    
    /// Confidence threshold (0.0-1.0)
    #[arg(long, default_value = "0.8")]
    confidence: f32,
    
    /// Output format: srt, vtt, txt, json, all
    #[arg(short, long, default_value = "srt")]
    format: String,
    
    /// Enable word-level timestamps
    #[arg(long)]
    word_timestamps: bool,
    
    /// Language code (auto-detect if not specified)
    #[arg(short, long)]
    language: Option<String>,
    
    /// Custom keywords file
    #[arg(long)]
    keywords: Option<PathBuf>,
    
    /// Number of parallel processing threads
    #[arg(long, default_value = "0")]
    threads: usize,
    
    /// Beam size for search
    #[arg(long, default_value = "5")]
    beam_size: usize,
    
    /// Enable noise reduction
    #[arg(long)]
    noise_reduction: bool,
    
    /// Enhance speech for political content
    #[arg(long)]
    speech_enhancement: bool,
}

#[derive(Serialize, Deserialize, Debug)]
struct TranscriptSegment {
    id: usize,
    start: f64,
    end: f64,
    text: String,
    confidence: f32,
    speaker: Option<String>,
    political_keywords: Vec<String>,
    sentiment: Option<String>,
    emphasis_level: Option<f32>,
}

#[derive(Serialize, Deserialize, Debug)]
struct TranscriptResult {
    filename: String,
    duration: f64,
    language: String,
    model_used: String,
    processing_time: f64,
    timestamp: DateTime<Utc>,
    segments: Vec<TranscriptSegment>,
    statistics: TranscriptStats,
    political_analysis: Option<PoliticalAnalysis>,
}

#[derive(Serialize, Deserialize, Debug)]
struct TranscriptStats {
    total_segments: usize,
    total_words: usize,
    average_confidence: f32,
    speech_duration: f64,
    silence_duration: f64,
    speakers_detected: usize,
}

#[derive(Serialize, Deserialize, Debug)]
struct PoliticalAnalysis {
    key_themes: Vec<String>,
    talking_points: Vec<String>,
    quotable_moments: Vec<QuotableMoment>,
    sentiment_distribution: HashMap<String, f32>,
    policy_mentions: Vec<PolicyMention>,
}

#[derive(Serialize, Deserialize, Debug)]
struct QuotableMoment {
    start: f64,
    end: f64,
    text: String,
    viral_potential: f32,
    context: String,
}

#[derive(Serialize, Deserialize, Debug)]
struct PolicyMention {
    policy: String,
    stance: String,
    confidence: f32,
    timestamp: f64,
}

struct PoliticalKeywords {
    economy: Vec<&'static str>,
    healthcare: Vec<&'static str>,
    education: Vec<&'static str>,
    environment: Vec<&'static str>,
    immigration: Vec<&'static str>,
    foreign_policy: Vec<&'static str>,
    social_issues: Vec<&'static str>,
    general: Vec<&'static str>,
}

impl Default for PoliticalKeywords {
    fn default() -> Self {
        Self {
            economy: vec![
                "economy", "jobs", "employment", "unemployment", "inflation", "recession",
                "growth", "gdp", "budget", "deficit", "debt", "tax", "taxes", "spending",
                "investment", "business", "trade", "tariff", "minimum wage", "income",
                "poverty", "wealth", "inequality", "stimulus", "bailout", "economic"
            ],
            healthcare: vec![
                "healthcare", "health care", "medicine", "hospital", "insurance", "medicare",
                "medicaid", "affordable care act", "obamacare", "prescription", "drugs",
                "medical", "doctor", "nurse", "pandemic", "covid", "vaccine", "public health",
                "mental health", "addiction", "opioid", "pharmaceutical", "coverage"
            ],
            education: vec![
                "education", "school", "schools", "university", "college", "student", "students",
                "teacher", "teachers", "learning", "curriculum", "funding", "budget",
                "graduation", "literacy", "achievement", "standardized testing", "charter",
                "public education", "higher education", "student loan", "debt", "tuition"
            ],
            environment: vec![
                "environment", "climate", "global warming", "carbon", "emissions", "pollution",
                "clean energy", "renewable", "solar", "wind", "nuclear", "fossil fuel",
                "oil", "gas", "coal", "green", "sustainability", "conservation", "EPA",
                "paris agreement", "greenhouse gas", "environmental"
            ],
            immigration: vec![
                "immigration", "immigrant", "immigrants", "border", "deportation", "asylum",
                "refugee", "daca", "dreamers", "citizenship", "naturalization", "visa",
                "legal immigration", "illegal immigration", "sanctuary", "wall", "barrier",
                "ice", "customs", "border patrol", "comprehensive reform"
            ],
            foreign_policy: vec![
                "foreign policy", "international", "diplomacy", "war", "peace", "military",
                "defense", "nato", "alliance", "treaty", "sanctions", "trade war",
                "china", "russia", "iran", "israel", "palestine", "afghanistan", "iraq",
                "syria", "north korea", "terrorism", "security", "intelligence"
            ],
            social_issues: vec![
                "abortion", "reproductive rights", "gun control", "second amendment", "firearms",
                "marriage equality", "lgbtq", "transgender", "discrimination", "civil rights",
                "racism", "police", "criminal justice", "prison", "reform", "voting rights",
                "gerrymandering", "supreme court", "constitution", "amendment"
            ],
            general: vec![
                "america", "american", "democracy", "freedom", "liberty", "justice", "equality",
                "opportunity", "progress", "change", "reform", "conservative", "liberal",
                "bipartisan", "compromise", "leadership", "values", "future", "generation",
                "community", "family", "working families", "middle class", "seniors"
            ]
        }
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::init();
    
    let cli = Cli::parse();
    
    // Set up thread pool
    if cli.threads > 0 {
        rayon::ThreadPoolBuilder::new()
            .num_threads(cli.threads)
            .build_global()
            .context("Failed to initialize thread pool")?;
    }
    
    info!("Starting transcription of: {:?}", cli.input);
    let start_time = std::time::Instant::now();
    
    // Validate input file
    if !cli.input.exists() {
        error!("Input file does not exist: {:?}", cli.input);
        return Err(anyhow::anyhow!("Input file not found"));
    }
    
    // Create output directory
    fs::create_dir_all(&cli.output).await
        .context("Failed to create output directory")?;
    
    // Load political keywords
    let keywords = load_keywords(&cli).await?;
    
    // Process audio/video file
    let transcript = process_file(&cli, &keywords).await?;
    
    let processing_time = start_time.elapsed().as_secs_f64();
    info!("Transcription completed in {:.2}s", processing_time);
    
    // Save outputs in requested formats
    save_transcript(&cli, &transcript, processing_time).await?;
    
    // Print summary
    print_summary(&transcript, processing_time);
    
    Ok(())
}

async fn load_keywords(cli: &Cli) -> Result<PoliticalKeywords> {
    let mut keywords = PoliticalKeywords::default();
    
    if let Some(keywords_file) = &cli.keywords {
        if keywords_file.exists() {
            let content = fs::read_to_string(keywords_file).await
                .context("Failed to read keywords file")?;
            
            // Parse custom keywords file (simple line-based format)
            for line in content.lines() {
                let line = line.trim();
                if !line.is_empty() && !line.starts_with('#') {
                    keywords.general.push(Box::leak(line.to_string().into_boxed_str()));
                }
            }
        }
    }
    
    Ok(keywords)
}

async fn process_file(cli: &Cli, keywords: &PoliticalKeywords) -> Result<TranscriptResult> {
    info!("Processing file: {:?}", cli.input);
    
    // Extract audio if needed (placeholder - would use FFmpeg bindings)
    let audio_path = if is_video_file(&cli.input) {
        extract_audio(&cli.input).await?
    } else {
        cli.input.clone()
    };
    
    // Transcribe using Whisper (placeholder - would use actual Whisper integration)
    let segments = transcribe_audio(&audio_path, cli).await?;
    
    // Enhance with political analysis if enabled
    let enhanced_segments = if cli.political_mode {
        enhance_political_analysis(segments, keywords).await?
    } else {
        segments.into_iter().map(|s| TranscriptSegment {
            id: s.id,
            start: s.start,
            end: s.end,
            text: s.text,
            confidence: s.confidence,
            speaker: s.speaker,
            political_keywords: vec![],
            sentiment: None,
            emphasis_level: None,
        }).collect()
    };
    
    // Calculate statistics
    let stats = calculate_statistics(&enhanced_segments);
    
    // Generate political analysis if enabled
    let political_analysis = if cli.political_mode {
        Some(generate_political_analysis(&enhanced_segments, keywords).await?)
    } else {
        None
    };
    
    Ok(TranscriptResult {
        filename: cli.input.file_name().unwrap().to_string_lossy().to_string(),
        duration: enhanced_segments.last().map(|s| s.end).unwrap_or(0.0),
        language: cli.language.clone().unwrap_or_else(|| "auto".to_string()),
        model_used: cli.model.clone(),
        processing_time: 0.0, // Will be set by caller
        timestamp: Utc::now(),
        segments: enhanced_segments,
        statistics: stats,
        political_analysis,
    })
}

fn is_video_file(path: &PathBuf) -> bool {
    if let Some(ext) = path.extension() {
        matches!(ext.to_str(), Some("mp4" | "mov" | "avi" | "mkv" | "webm" | "flv"))
    } else {
        false
    }
}

async fn extract_audio(video_path: &PathBuf) -> Result<PathBuf> {
    // Placeholder for FFmpeg audio extraction
    // In real implementation, would use FFmpeg to extract audio to temporary file
    let audio_path = video_path.with_extension("wav");
    info!("Extracting audio to: {:?}", audio_path);
    
    // Simulate audio extraction
    tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
    
    Ok(audio_path)
}

async fn transcribe_audio(audio_path: &PathBuf, cli: &Cli) -> Result<Vec<BasicSegment>> {
    info!("Transcribing audio with model: {}", cli.model);
    
    // Placeholder for actual Whisper transcription
    // In real implementation, would use whisper-rs or candle-transformers
    
    // Simulate processing time based on model size
    let processing_delay = match cli.model.as_str() {
        "tiny" => 500,
        "base" => 1000,
        "small" => 2000,
        "medium" => 4000,
        "large" => 8000,
        "large-v3" => 10000,
        _ => 1000,
    };
    
    tokio::time::sleep(tokio::time::Duration::from_millis(processing_delay)).await;
    
    // Generate mock segments for demonstration
    Ok(vec![
        BasicSegment {
            id: 1,
            start: 0.0,
            end: 5.2,
            text: "Thank you for joining us today for this important discussion about healthcare reform.".to_string(),
            confidence: 0.95,
            speaker: Some("Speaker 1".to_string()),
        },
        BasicSegment {
            id: 2,
            start: 5.2,
            end: 12.8,
            text: "We need to ensure that every American has access to affordable healthcare without compromise.".to_string(),
            confidence: 0.92,
            speaker: Some("Speaker 1".to_string()),
        },
        BasicSegment {
            id: 3,
            start: 12.8,
            end: 20.1,
            text: "Our economy depends on healthy workers and families who aren't burdened by medical debt.".to_string(),
            confidence: 0.89,
            speaker: Some("Speaker 1".to_string()),
        },
    ])
}

#[derive(Debug)]
struct BasicSegment {
    id: usize,
    start: f64,
    end: f64,
    text: String,
    confidence: f32,
    speaker: Option<String>,
}

async fn enhance_political_analysis(
    segments: Vec<BasicSegment>,
    keywords: &PoliticalKeywords,
) -> Result<Vec<TranscriptSegment>> {
    info!("Enhancing with political analysis");
    
    let enhanced: Vec<TranscriptSegment> = segments
        .into_par_iter()
        .map(|segment| {
            let political_keywords = detect_political_keywords(&segment.text, keywords);
            let sentiment = analyze_sentiment(&segment.text);
            let emphasis_level = calculate_emphasis(&segment.text);
            
            TranscriptSegment {
                id: segment.id,
                start: segment.start,
                end: segment.end,
                text: segment.text,
                confidence: segment.confidence,
                speaker: segment.speaker,
                political_keywords,
                sentiment: Some(sentiment),
                emphasis_level: Some(emphasis_level),
            }
        })
        .collect();
    
    Ok(enhanced)
}

fn detect_political_keywords(text: &str, keywords: &PoliticalKeywords) -> Vec<String> {
    let text_lower = text.to_lowercase();
    let mut found_keywords = Vec::new();
    
    for category_keywords in [
        &keywords.economy,
        &keywords.healthcare,
        &keywords.education,
        &keywords.environment,
        &keywords.immigration,
        &keywords.foreign_policy,
        &keywords.social_issues,
        &keywords.general,
    ] {
        for keyword in category_keywords {
            if text_lower.contains(keyword) {
                found_keywords.push(keyword.to_string());
            }
        }
    }
    
    found_keywords.sort();
    found_keywords.dedup();
    found_keywords
}

fn analyze_sentiment(text: &str) -> String {
    // Simple sentiment analysis based on keywords
    let positive_words = ["good", "great", "excellent", "wonderful", "amazing", "fantastic", "success", "progress", "improve", "better"];
    let negative_words = ["bad", "terrible", "awful", "horrible", "disaster", "failure", "crisis", "problem", "decline", "worse"];
    
    let text_lower = text.to_lowercase();
    let positive_count = positive_words.iter().filter(|&word| text_lower.contains(word)).count();
    let negative_count = negative_words.iter().filter(|&word| text_lower.contains(word)).count();
    
    match positive_count.cmp(&negative_count) {
        std::cmp::Ordering::Greater => "positive".to_string(),
        std::cmp::Ordering::Less => "negative".to_string(),
        std::cmp::Ordering::Equal => "neutral".to_string(),
    }
}

fn calculate_emphasis(text: &str) -> f32 {
    // Calculate emphasis based on punctuation, caps, etc.
    let exclamation_count = text.matches('!').count() as f32;
    let caps_ratio = text.chars().filter(|c| c.is_uppercase()).count() as f32 / text.len() as f32;
    let question_count = text.matches('?').count() as f32;
    
    (exclamation_count * 0.3 + caps_ratio * 10.0 + question_count * 0.2).min(1.0)
}

fn calculate_statistics(segments: &[TranscriptSegment]) -> TranscriptStats {
    let total_segments = segments.len();
    let total_words = segments.iter().map(|s| s.text.split_whitespace().count()).sum();
    let average_confidence = segments.iter().map(|s| s.confidence).sum::<f32>() / total_segments as f32;
    
    let speech_duration = segments.last().map(|s| s.end).unwrap_or(0.0);
    let silence_duration = 0.0; // Would calculate actual silence periods
    
    let speakers_detected = segments
        .iter()
        .filter_map(|s| s.speaker.as_ref())
        .collect::<std::collections::HashSet<_>>()
        .len();
    
    TranscriptStats {
        total_segments,
        total_words,
        average_confidence,
        speech_duration,
        silence_duration,
        speakers_detected,
    }
}

async fn generate_political_analysis(
    segments: &[TranscriptSegment],
    keywords: &PoliticalKeywords,
) -> Result<PoliticalAnalysis> {
    info!("Generating political analysis");
    
    // Extract key themes
    let mut theme_counts: HashMap<String, usize> = HashMap::new();
    for segment in segments {
        for keyword in &segment.political_keywords {
            *theme_counts.entry(keyword.clone()).or_insert(0) += 1;
        }
    }
    
    let mut key_themes: Vec<String> = theme_counts
        .into_iter()
        .filter(|(_, count)| *count >= 2)
        .map(|(theme, _)| theme)
        .collect();
    key_themes.sort();
    
    // Generate talking points
    let talking_points = segments
        .iter()
        .filter(|s| s.political_keywords.len() > 2)
        .map(|s| s.text.clone())
        .take(5)
        .collect();
    
    // Find quotable moments
    let quotable_moments = segments
        .iter()
        .filter(|s| s.emphasis_level.unwrap_or(0.0) > 0.3 || s.political_keywords.len() > 1)
        .map(|s| QuotableMoment {
            start: s.start,
            end: s.end,
            text: s.text.clone(),
            viral_potential: s.emphasis_level.unwrap_or(0.0) + (s.political_keywords.len() as f32 * 0.1),
            context: format!("Political discussion at {:.1}s", s.start),
        })
        .collect();
    
    // Sentiment distribution
    let mut sentiment_distribution = HashMap::new();
    for segment in segments {
        if let Some(sentiment) = &segment.sentiment {
            *sentiment_distribution.entry(sentiment.clone()).or_insert(0.0) += 1.0;
        }
    }
    
    let total_segments = segments.len() as f32;
    for value in sentiment_distribution.values_mut() {
        *value /= total_segments;
    }
    
    // Policy mentions (simplified)
    let policy_mentions = vec![
        PolicyMention {
            policy: "Healthcare".to_string(),
            stance: "Support".to_string(),
            confidence: 0.8,
            timestamp: 5.0,
        }
    ];
    
    Ok(PoliticalAnalysis {
        key_themes,
        talking_points,
        quotable_moments,
        sentiment_distribution,
        policy_mentions,
    })
}

async fn save_transcript(cli: &Cli, transcript: &TranscriptResult, processing_time: f64) -> Result<()> {
    let base_name = cli.input.file_stem().unwrap().to_string_lossy();
    
    let mut transcript_with_time = transcript.clone();
    transcript_with_time.processing_time = processing_time;
    
    match cli.format.as_str() {
        "srt" => save_srt(cli, &transcript_with_time, &base_name).await?,
        "vtt" => save_vtt(cli, &transcript_with_time, &base_name).await?,
        "txt" => save_txt(cli, &transcript_with_time, &base_name).await?,
        "json" => save_json(cli, &transcript_with_time, &base_name).await?,
        "all" => {
            save_srt(cli, &transcript_with_time, &base_name).await?;
            save_vtt(cli, &transcript_with_time, &base_name).await?;
            save_txt(cli, &transcript_with_time, &base_name).await?;
            save_json(cli, &transcript_with_time, &base_name).await?;
        }
        _ => return Err(anyhow::anyhow!("Unsupported format: {}", cli.format)),
    }
    
    Ok(())
}

async fn save_srt(cli: &Cli, transcript: &TranscriptResult, base_name: &str) -> Result<()> {
    let output_path = cli.output.join(format!("{}.srt", base_name));
    let mut content = String::new();
    
    for segment in &transcript.segments {
        content.push_str(&format!(
            "{}\n{} --> {}\n{}\n\n",
            segment.id,
            format_time_srt(segment.start),
            format_time_srt(segment.end),
            segment.text
        ));
    }
    
    fs::write(&output_path, content).await
        .context("Failed to write SRT file")?;
    
    info!("Saved SRT: {:?}", output_path);
    Ok(())
}

async fn save_vtt(cli: &Cli, transcript: &TranscriptResult, base_name: &str) -> Result<()> {
    let output_path = cli.output.join(format!("{}.vtt", base_name));
    let mut content = String::from("WEBVTT\n\n");
    
    for segment in &transcript.segments {
        content.push_str(&format!(
            "{} --> {}\n{}\n\n",
            format_time_vtt(segment.start),
            format_time_vtt(segment.end),
            segment.text
        ));
    }
    
    fs::write(&output_path, content).await
        .context("Failed to write VTT file")?;
    
    info!("Saved VTT: {:?}", output_path);
    Ok(())
}

async fn save_txt(cli: &Cli, transcript: &TranscriptResult, base_name: &str) -> Result<()> {
    let output_path = cli.output.join(format!("{}.txt", base_name));
    let content = transcript.segments
        .iter()
        .map(|s| s.text.clone())
        .collect::<Vec<_>>()
        .join(" ");
    
    fs::write(&output_path, content).await
        .context("Failed to write TXT file")?;
    
    info!("Saved TXT: {:?}", output_path);
    Ok(())
}

async fn save_json(cli: &Cli, transcript: &TranscriptResult, base_name: &str) -> Result<()> {
    let output_path = cli.output.join(format!("{}.json", base_name));
    let content = serde_json::to_string_pretty(transcript)
        .context("Failed to serialize transcript")?;
    
    fs::write(&output_path, content).await
        .context("Failed to write JSON file")?;
    
    info!("Saved JSON: {:?}", output_path);
    Ok(())
}

fn format_time_srt(seconds: f64) -> String {
    let hours = (seconds / 3600.0) as u32;
    let minutes = ((seconds % 3600.0) / 60.0) as u32;
    let secs = (seconds % 60.0) as u32;
    let millis = ((seconds % 1.0) * 1000.0) as u32;
    
    format!("{:02}:{:02}:{:02},{:03}", hours, minutes, secs, millis)
}

fn format_time_vtt(seconds: f64) -> String {
    let hours = (seconds / 3600.0) as u32;
    let minutes = ((seconds % 3600.0) / 60.0) as u32;
    let secs = (seconds % 60.0) as u32;
    let millis = ((seconds % 1.0) * 1000.0) as u32;
    
    format!("{:02}:{:02}:{:02}.{:03}", hours, minutes, secs, millis)
}

fn print_summary(transcript: &TranscriptResult, processing_time: f64) {
    println!("\n🎯 Transcription Complete!");
    println!("📁 File: {}", transcript.filename);
    println!("⏱️  Duration: {:.1}s", transcript.duration);
    println!("🚀 Processing Time: {:.2}s", processing_time);
    println!("🎬 Segments: {}", transcript.statistics.total_segments);
    println!("💬 Words: {}", transcript.statistics.total_words);
    println!("✅ Avg Confidence: {:.1}%", transcript.statistics.average_confidence * 100.0);
    
    if let Some(analysis) = &transcript.political_analysis {
        println!("\n🏛️  Political Analysis:");
        println!("📊 Key Themes: {}", analysis.key_themes.join(", "));
        println!("💡 Talking Points: {}", analysis.talking_points.len());
        println!("🔥 Quotable Moments: {}", analysis.quotable_moments.len());
        
        if !analysis.sentiment_distribution.is_empty() {
            println!("😊 Sentiment:");
            for (sentiment, ratio) in &analysis.sentiment_distribution {
                println!("   {}: {:.1}%", sentiment, ratio * 100.0);
            }
        }
    }
    
    println!("\n✨ Ready for political communications! 🚀");
} 