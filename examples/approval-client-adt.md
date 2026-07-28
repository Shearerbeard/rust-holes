# Worked example: an approval client's type surface

A small HTTP client that posts a human's approval decision to a server.
Roughly 170 lines in its real form. It is the canonical Layer 1 exemplar
because the whole design argument fits on one screen and one real bug was
caught at the typing stage, before any body existed.

Rules applied here: `../PLAYBOOK.md`, section "Layer 1".

## The domain

A pending request is shown to a human, who approves or denies it. A denial
carries a reason; an approval does not. The client posts the decision to a
server that may or may not still know about the request.

## The skeleton

```rust
/// The human's decision.
///
/// `Approved` carries no payload. An approval reason has no consumer, and
/// a field with no consumer invites a caller to put a denial reason in it.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Decision {
    Approved,
    Denied { reason: DenialReason },
}

/// A non-empty denial reason. Parse, do not validate.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DenialReason(String);

impl DenialReason {
    pub fn new(raw: impl Into<String>) -> Result<Self, DecisionError> {
        let raw = raw.into();
        if raw.trim().is_empty() {
            return Err(DecisionError::EmptyReason);
        }
        Ok(Self(raw))
    }
}

impl AsRef<str> for DenialReason {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

/// What the server did with a well-formed post.
///
/// Two outcomes, not a bool and not an Option: `NotFound` is a normal
/// result (the request expired or another client answered first), so it
/// must not be modeled as an error.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum PostOutcome {
    Accepted,
    NotFound,
}

/// Why a post failed to produce an outcome.
///
/// Three variants, kept distinct because a caller acts differently on
/// each: a transport failure is retryable, a body-read failure means the
/// connection died mid-response, and an unexpected status means the
/// server and this client disagree about the protocol.
///
/// `UnexpectedStatus.body` is the unparsed response text, carried for
/// diagnostics only: it exists to be logged and shown to a human, and no
/// caller branches on its contents. That is the exception the boundary
/// rule allows. Anything a caller must act on gets a type instead.
#[derive(Debug, thiserror::Error)]
pub enum PostError {
    #[error("request failed: {0}")]
    Transport(#[source] reqwest::Error),
    #[error("response body read failed: {0}")]
    BodyRead(#[source] reqwest::Error),
    #[error("unexpected status {status}: {body}")]
    UnexpectedStatus { status: StatusCode, body: String },
}

#[derive(Debug, thiserror::Error)]
pub enum DecisionError {
    #[error("denial reason is empty")]
    EmptyReason,
}

pub struct ApprovalClient {
    base: Url,
    http: reqwest::Client,
}

impl ApprovalClient {
    pub fn new(base: Url, http: reqwest::Client) -> Self {
        Self { base, http }
    }

    #[expect(unused_variables, reason = "todo!() body; filled by the post card")]
    pub async fn post(
        &self,
        request_id: RequestId,
        decision: Decision,
    ) -> Result<PostOutcome, PostError> {
        todo!()
    }
}
```

## What the type surface buys

| Type | Business rule | Forbidden invalid state |
|---|---|---|
| `Decision` | An approval has no reason; a denial always has one | An approval carrying a reason; a denial with none |
| `DenialReason` | A denial reason is non-empty text | An empty or whitespace-only reason reaching the server |
| `PostOutcome` | A well-formed post either lands or finds no request; both are normal | `NotFound` surfacing as an error a caller must catch to treat as normal |
| `PostError` | The three failure modes a caller acts on differently stay distinct | Collapsing transport, body-read, and protocol disagreement into one opaque error |

The four rows are the whole design review. Each is checkable against the
types alone, with no body written.

## The bug the compiler stage caught

The event stream this client consumes had a `Pending` variant and a
`Requested` variant, both arms of one enum carrying a
`#[serde(untagged)]` derive. `Pending` was declared first and its fields
were a structural subset of `Requested`'s. Untagged deserialization tries
the variants in declaration order and returns the first that succeeds,
and a `Requested` payload carries everything `Pending` needs, so every
`Requested` event would have deserialized as `Pending` with the extra
fields dropped.

That is runtime deserialization behavior. Nothing is ill-typed and the
compiler never flags it. What the typing stage buys is that the risk is
visible by inspection, to anyone reading the two variants' field shapes
side by side, which is exactly what laying the full surface before
writing bodies forces someone to do. It is also seat 1 question 6 of the
design panel prompt.

The general rule: `serde(untagged)` over enums with overlapping field
shapes is a class of bug the compiler will not catch, so the typing stage
is where someone has to look for it.

## Notes on scale

This module compiled after three precise fixes on a first pass, and a
larger sibling module (an eight-file domain plus config, events, and a
call-wrapper hook) compiled on its first pass at several hundred lines of
diff. The skeleton stage is where the compile cost is paid; it is small
because there are no bodies to debug.

The same sibling module carried the known limit: a real defect at a
partly-private ingress path survived the green skeleton, because nothing
ill-typed was written. Agent review at the design panel caught it. See
"Known limits" in the playbook.
