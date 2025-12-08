//
//  ProfilePrompt.swift
//  CoFoundry
//
//  Professional prompts for engaging co-founder profiles
//

import Foundation

struct ProfilePrompt: Codable, Identifiable, Equatable {
    var id: String
    var question: String
    var answer: String

    init(id: String = UUID().uuidString, question: String, answer: String) {
        self.id = id
        self.question = question
        self.answer = answer
    }

    func toDictionary() -> [String: String] {
        return [
            "id": id,
            "question": question,
            "answer": answer
        ]
    }
}

// MARK: - Available Prompts

struct PromptLibrary {
    static let allPrompts: [String] = [
        // Vision & Mission
        "The problem I want to solve is...",
        "My startup idea in one sentence is...",
        "I'm building this because...",
        "The impact I want to make is...",
        "My vision for the next 5 years is...",
        "The industry I want to disrupt is...",

        // Skills & Experience
        "My superpower as a co-founder is...",
        "My technical expertise includes...",
        "My business experience includes...",
        "The skills I bring to the table are...",
        "My biggest professional achievement is...",
        "I've learned the most from...",

        // What You're Looking For
        "I'm looking for a co-founder who...",
        "The ideal partnership for me looks like...",
        "I work best with people who...",
        "A deal-breaker in a co-founder is...",
        "The role I need filled is...",
        "Together we could...",

        // Work Style & Values
        "My work style is best described as...",
        "I believe the key to startup success is...",
        "My approach to problem-solving is...",
        "I handle disagreements by...",
        "My communication style is...",
        "Work-life balance to me means...",

        // Startup Experience
        "My startup journey so far...",
        "The biggest lesson from my past ventures is...",
        "I failed at a startup because...",
        "What I learned from building products is...",
        "My experience with fundraising is...",
        "The toughest business decision I made was...",

        // Goals & Commitment
        "My timeline for launching is...",
        "I'm ready to commit because...",
        "My equity expectations are...",
        "I define success for this venture as...",
        "Where I see this startup in 3 years...",
        "My biggest goal this year is...",

        // Industry & Market
        "The market opportunity I see is...",
        "My unfair advantage in this space is...",
        "I understand this industry because...",
        "The trend I'm betting on is...",
        "My target customers are...",
        "The competition doesn't see...",

        // Resources & Network
        "I can bring to the table...",
        "My network includes connections in...",
        "The resources I have access to are...",
        "I can help with fundraising by...",
        "My advisory network includes...",

        // Personal & Motivation
        "What drives me as an entrepreneur is...",
        "I'm passionate about startups because...",
        "Outside of work, I'm interested in...",
        "A fun fact about my entrepreneurial journey...",
        "The book that shaped my business thinking is...",
        "My entrepreneur role model is...",

        // Hot Takes & Opinions
        "An unpopular opinion I have about startups is...",
        "I believe most founders get wrong...",
        "The startup advice I disagree with is...",
        "My controversial take on funding is...",
        "The hill I'll die on in business is..."
    ]

    static let categories: [String: [String]] = [
        "Vision & Mission": [
            "The problem I want to solve is...",
            "My startup idea in one sentence is...",
            "I'm building this because...",
            "The impact I want to make is..."
        ],
        "Skills & Experience": [
            "My superpower as a co-founder is...",
            "My technical expertise includes...",
            "My business experience includes...",
            "My biggest professional achievement is..."
        ],
        "Looking For": [
            "I'm looking for a co-founder who...",
            "The ideal partnership for me looks like...",
            "I work best with people who...",
            "The role I need filled is..."
        ],
        "Work Style": [
            "My work style is best described as...",
            "My approach to problem-solving is...",
            "I handle disagreements by...",
            "My communication style is..."
        ],
        "Goals & Commitment": [
            "My timeline for launching is...",
            "I'm ready to commit because...",
            "My equity expectations are...",
            "Where I see this startup in 3 years..."
        ],
        "Hot Takes": [
            "An unpopular opinion I have about startups is...",
            "I believe most founders get wrong...",
            "My controversial take on funding is...",
            "The hill I'll die on in business is..."
        ]
    ]

    static func randomPrompts(count: Int = 5) -> [String] {
        return Array(allPrompts.shuffled().prefix(count))
    }

    static func suggestedPrompts() -> [String] {
        // Return a curated mix of prompts for new users
        return [
            "The problem I want to solve is...",
            "I'm looking for a co-founder who...",
            "My superpower as a co-founder is...",
            "My startup idea in one sentence is...",
            "My work style is best described as..."
        ]
    }
}
