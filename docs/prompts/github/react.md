# react

Add an emoji reaction to a GitHub issue, pull request, or specific comment using natural language.

## When to Use It

- Acknowledging an issue report without posting a comment
- Upvoting a feature request or important PR
- Adding thumbs-up to a specific comment without cluttering the thread
- Expressing sentiment on a discussion post

## How to Launch It

**In GitHub Copilot Chat:**

```text
/react owner/repo#89 
```

Or with natural language:

```text
/react owner/repo#89 thumbs up
/react owner/repo#89 I love this idea
/react owner/repo#89 heart the latest comment
```

## What to Expect

1. **Parse intent** - Identifies reaction type from emoji, name, or natural language
2. **Identify target** - Issue/PR or specific comment (latest or by number)
3. **Preview** - Shows which item will receive the reaction
4. **Add reaction** - Posts via GitHub API immediately (reactions are non-destructive)

### Natural Language to Reaction Mapping

| You say | Reaction added |
|---------|----------------|
| thumbs up / +1 / great / agree /  |  +1 |
| thumbs down / -1 / disagree /  |  -1 |
| laugh / funny / lol /  |  laugh |
| hooray / celebrate / party /  |  hooray |
| confused / not sure /  |  confused |
| heart / love /  |  heart |
| rocket / let's go /  |  rocket |
| eyes / watching / looking /  |  eyes |

### Target Selection

| You say | Where the reaction goes |
|---------|------------------------|
| (nothing) | The issue/PR itself |
| `latest comment` | The most recent comment |
| `@alice's comment` | The most recent comment by alice |
| `comment #3` | The third comment in the thread |

### Sample Flow

```text
You: /react owner/repo#89 heart the latest comment

Agent: Adding  to the latest comment on #89:
  @alice (2 hours ago): "This is fixed in PR #102"

Reaction added. 
```

## Example Variations

```text
/react owner/repo#89 
/react #89 thumbs up
/react #89 I love this idea
/react #89 heart the latest comment
/react #89 rocket                        #  on the issue itself
```

## Connected Agents

| Agent | Role |
|-------|------|
| issue-tracker agent | Executes this prompt |

## Related Prompts

- [issue-reply](issue-reply.md) - draft and post a written reply
- [manage-issue](manage-issue.md) - label, assign, close issues
