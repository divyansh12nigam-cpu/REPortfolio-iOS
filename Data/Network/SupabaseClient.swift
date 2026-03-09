import Foundation
import Supabase

/// Supabase client singleton.
enum SupabaseManager {
    private static let projectURL = URL(string: "https://vrjplyglmgvesmmrzazx.supabase.co")!
    private static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZyanBseWdsbWd2ZXNtbXJ6YXp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwMzYxNDAsImV4cCI6MjA4ODYxMjE0MH0.cjOL-7TZ1kAK2kuOsHZFs-PHqXIhA-r1lfTKXeXlXnA"

    static let client = SupabaseClient(
        supabaseURL: projectURL,
        supabaseKey: anonKey
    )
}
