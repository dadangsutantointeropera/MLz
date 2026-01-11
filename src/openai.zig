const std = @import("std");

/// OpenAI-compatible types for `/v1/chat/completions`.
///
/// We intentionally ignore unknown fields so that common OpenAI client SDKs work
/// without needing exact schema parity.
pub const Role = enum { system, user, assistant, tool };

pub const ChatMessage = struct {
    role: []const u8,
    content: []const u8,
    name: ?[]const u8 = null,
};

pub const ChatCompletionRequest = struct {
    model: ?[]const u8 = null,
    messages: []ChatMessage,

    temperature: ?f32 = null,
    top_p: ?f32 = null,
    max_tokens: ?u32 = null,
    stream: ?bool = null,
    seed: ?u32 = null,
};

pub const Usage = struct {
    prompt_tokens: usize,
    completion_tokens: usize,
    total_tokens: usize,
};

pub const ChatCompletionChoice = struct {
    index: usize,
    message: struct {
        role: []const u8,
        content: []const u8,
    },
    finish_reason: []const u8,
};

pub const ChatCompletionResponse = struct {
    id: []const u8,
    object: []const u8,
    created: i64,
    model: []const u8,
    choices: []const ChatCompletionChoice,
    usage: Usage,
};

pub const ChatCompletionChunkChoice = struct {
    index: usize,
    delta: struct {
        role: ?[]const u8 = null,
        content: ?[]const u8 = null,
    },
    finish_reason: ?[]const u8 = null,
};

pub const ChatCompletionChunk = struct {
    id: []const u8,
    object: []const u8,
    created: i64,
    model: []const u8,
    choices: []const ChatCompletionChunkChoice,
};

pub const ErrorResponse = struct {
    @"error": struct {
        message: []const u8,
        type: []const u8,
        param: ?[]const u8 = null,
        code: ?[]const u8 = null,
    },
};

pub const ParseError = error{ InvalidJson, MissingMessages };

/// Parse a JSON request body into `ChatCompletionRequest`.
///
/// - Requires `messages` to be present.
/// - Unknown fields are ignored.
pub fn parseChatCompletionRequest(
    allocator: std.mem.Allocator,
    body: []const u8,
) !std.json.Parsed(ChatCompletionRequest) {
    var parsed = std.json.parseFromSlice(
        ChatCompletionRequest,
        allocator,
        body,
        .{ .ignore_unknown_fields = true },
    ) catch return ParseError.InvalidJson;

    if (parsed.value.messages.len == 0) {
        parsed.deinit();
        return ParseError.MissingMessages;
    }

    return parsed;
}

/// Write JSON with stable settings.
pub fn writeJson(writer: anytype, value: anytype) !void {
    const WriterIface = std.io.Writer;
    const WT = @TypeOf(writer);

    if (WT == *WriterIface) {
        var jw = std.json.Stringify{ .writer = writer, .options = .{ .whitespace = .minified } };
        try jw.write(value);
        return;
    }

    // Bridge deprecated/legacy writers (e.g. std.io.GenericWriter) to the new Writer API.
    var w = writer;
    if (@hasDecl(@TypeOf(w), "adaptToNewApi")) {
        var buf: [8 * 1024]u8 = undefined;
        var adapter = w.adaptToNewApi(&buf);
        var jw = std.json.Stringify{ .writer = &adapter.new_interface, .options = .{ .whitespace = .minified } };
        try jw.write(value);
        if (adapter.err) |err| return err;
        return;
    }

    @compileError("openai.writeJson: unsupported writer type; pass *std.io.Writer or a writer supporting adaptToNewApi()");
}
