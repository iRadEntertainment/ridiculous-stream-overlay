# User games: changes and validation

Completed September 25–26, 2026.

Steam and itch.io game additions, removals, and successful metadata updates now save automatically. Selecting a visible user panel also schedules one automatic refresh attempt per game per application launch, with bounded concurrency and diagnostic logging.

This work implements the game-related fixes identified in [the known-users review](known-users-review.md). That review describes the earlier implementation and remains a historical assessment; its game-related findings should be read alongside this document.

## Commit organization

| Order | Commit subject | Scope |
| --- | --- | --- |
| 1 | `fix: autosave user games and harden metadata handling` | Serialization, add/delete/update persistence, failure rollback, selection guards, API request validation and cleanup, manual-edit regression tests. |
| 2 | `feat: refresh selected users games in staggered batches` | Session refresh queue, visible-panel integration, automatic persistence, diagnostic logging configuration, queue regression tests. |
| 3 | `fix: match Steam app details by embedded app ID` | Response-key mismatch handling, strict identity verification, parser and UI persistence regression tests. |
| 4 | `docs: summarize known-user review and game improvements` | Original investigation and this implementation summary. |

The independent local editor-preview changes in `lib/games_info/pnl_itchio_app_info.tscn` are not included in this commit series. Captured HTTP responses, test output, and isolated test data remain under the ignored `.godot/` directory.

## Automatic persistence for game edits

- Adding a Steam or itch.io game saves the association and its retrieved metadata immediately.
- The Steam Add button accepts an app ID or a Steam store URL.
- New itch.io entries use the returned canonical URL; trailing-slash variants do not create duplicate entries.
- The entry Update button saves successful retrievals to the selected user's record before replacing the displayed data.
- Delete now removes the saved association, not just the entry widget.
- A failed save restores the previous association in memory and leaves the existing entry visible. The games panel displays an error.
- Failed or mismatched API results preserve existing data. Refresh buttons become available again for retries.
- Merely populating a panel from cached game data does not save the user or start entry-level metadata requests.
- Asynchronous additions retain their original selection context. Switching users invalidates stale additions, and updates cannot re-add a user removed from the known list.
- Concurrent additions keep their own API responses rather than sharing a mutable panel result.

The manual Save workflow for other user fields was not redesigned. Game autosaves still use the existing whole-user JSON writer, so other in-memory user edits can be included in that write; this work does not introduce separate per-field transactions.

Primary files: [pnl_user_games.gd](../instances/users/pnl_user_games.gd), [entry_game_list.gd](../instances/entries/entry_game_list.gd), and [pnl_user_games.tscn](../instances/users/pnl_user_games.tscn).

## Game serialization and API handling

`RSUser.to_dict()` now emits Steam association keys as strings. Decoding accepts both JSON string keys and legacy integer keys, restoring numeric IDs in memory. This fixes the direct snapshot round trip used by profile rollback. Invalid association keys and non-dictionary records are skipped for both stores.

Steam metadata decoding also handles string age values and absent/non-dictionary PC requirements. Missing developer/release-date fields no longer break the affected display paths, and an empty image URL does not start an image request.

Both store services now use a 30-second timeout per HTTP request, release request nodes on failure, and check transport success as well as HTTP status. itch.io validates the game ID and canonical URL. Its JSON and HTML retrieval must both succeed so a partial refresh cannot erase saved descriptions and screenshots.

Primary files: [RSUser.gd](../classes/RSUser.gd), [SteamAppData.gd](../lib/games_info/SteamAppData.gd), [SteamService.gd](../lib/games_info/SteamService.gd), and [ItchIOService.gd](../lib/games_info/ItchIOService.gd).

## Once-per-launch background refresh

The queue belongs to `RSUserMng`, so closing or rebuilding the UI does not reset its session history.

| Behavior | Value |
| --- | --- |
| Trigger | A known user is selected while the games panel is visible, or the selected panel becomes visible. |
| Immediate display | Previously saved game information. |
| Initial delay | 250 ms. |
| Batch size | Up to five game refresh jobs shared across selected users and both stores. |
| Stagger | 300 ms between job starts within a batch. |
| Batch pause | Two seconds after all jobs in the previous batch complete. |
| Automatic attempts | One per user/store/game key per application launch, including failures. |
| Manual retry | Entry Update remains available. |
| Persistence | Successful automatic results save immediately. |

Each itch.io job performs its JSON and HTML requests sequentially. The limit applies to automatic metadata jobs; manual requests and image downloads use their existing paths.

Switching selection does not cancel work already queued for the previous user: results can still be saved to that original user. A removed/replaced user, removed game, or newer game edit invalidates the result. An automatic refresh updates entries and matching visible details without opening or switching the details tab.

Successful manual additions and updates mark the game current for the session, avoiding a redundant automatic fetch. No refresh flags are written to user JSON; restarting the application allows another attempt.

Primary files: [RSUserGameRefresh.gd](../classes/RSUserGameRefresh.gd), [RSUserMng.gd](../classes/RSUserMng.gd), and [pnl_user_games.gd](../instances/users/pnl_user_games.gd).

## Refresh diagnostics

The project enables `info` logging for `RSUserGameRefresh`, `SteamService`, and `ItchIOService` through `twitcher/logs/...` settings.

- Info output covers triggers, queue counts, request starts, batch pauses/completion, successful saves, elapsed time, and skipped/discarded jobs.
- Warnings identify unusable API results, identity mismatches, and session retry behavior.
- Errors identify transport/HTTP failures, invalid response shapes, and save failures with rollback.
- Messages include the relevant user ID, store, app ID or URL. itch.io JSON and HTML stages are logged separately.
- Setting a logger to `debug` adds its detailed diagnostic messages; `off` disables it.

## Steam app 4483400 investigation and fix

The direct response captured for app `4483400` returned HTTP 200 and successful metadata for **MR MAGEBOY**, but used outer key `5310040`. The metadata itself contained `steam_appid: 4483400`. An English-language request showed the same mismatch. A control request for Dota 2 also returned an outer key different from its embedded app ID.

The original exact-key lookup therefore rejected valid metadata. The parser now first checks the expected record, then searches other successful records for the requested embedded `steam_appid`. It rejects unrelated records and ambiguous fallback matches, preserves the requested ID as the association key, and logs the mismatch. It does not assume that the first returned record is correct.

This behavior was verified against the captured responses and through the real UI Add handler with a controlled API reply and isolated JSON persistence.

## Validation

| Test script | Recorded result | Coverage |
| --- | --- | --- |
| [test_user_games.gd](../test/test_user_games.gd) | 25 checks passed | Snapshot/JSON round trips, manual add/update/delete, canonical URLs, API failure, save rollback, selection changes, concurrent additions, deletion guards. |
| [test_user_game_refresh.gd](../test/test_user_game_refresh.gd) | 35 checks passed | Visibility trigger, five-job limit, request staggering, batch pause, correct-user persistence, deduplication, UI recreation, session reset, stale-result rejection, failure handling. |
| [test_steam_service.gd](../test/test_steam_service.gd) | 15 checks passed | Response identity matching, invalid/ambiguous responses, captured Steam payloads, UI Add persistence. |

The Steam suite includes three optional checks against captured responses in `.godot/`. A checkout without those captures runs 12 checks in that suite, for 72 total rather than the 75 recorded here.

Tests use controlled API replies and real serialization/persistence in isolated application data. The Steam investigation additionally made direct read-only requests to the public store endpoint. The tests do not claim a full live-network UI session. Godot import reported no script errors after the implementation fixes; existing Rapier/editor shutdown diagnostics and sandbox certificate-store messages remain outside this change.

To run the suites in PowerShell from the repository root:

```powershell
$godotExe = 'C:/Godot/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = Join-Path (Get-Location).Path '.godot/user-games-test-data'
    foreach ($suite in @('test_user_games', 'test_user_game_refresh', 'test_steam_service')) {
        & $godotExe --headless --path . --script "res://test/$suite.gd"
        if ($LASTEXITCODE -ne 0) { throw "Failed: $suite" }
    }
} finally {
    $env:APPDATA = $previousAppData
}
```

For a fresh checkout, first import the project with the matching Godot version so its class/resource cache is available. The tests intentionally refuse to run without the isolated application-data path.

## Scope left for later

Vetting identities and administration, known-user trust semantics, general Reload behavior, and the broader user repository/editor refactor were investigated but not implemented. The original review contains those outstanding findings. This series focuses on game metadata, persistence, refresh scheduling, and observability in the current implementation.
