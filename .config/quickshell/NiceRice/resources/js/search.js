.pragma library

const W = { name: 1.0, generic: 0.6, keywords: 0.5 }

// Score one field against the query: 0 (no match) to 1 (exact)
function scoreField(q, s) {
    if (!s) return 0
    if (s === q) return 1
    if (s.startsWith(q)) return 0.9

    // match at the start of a later word ("code" in "Visual Studio Code")
    let idx = s.indexOf(q)
    while (idx >= 0) {
        if (idx === 0 || /[\s\-_.]/.test(s[idx - 1])) return 0.75
        idx = s.indexOf(q, idx + 1)
    }

    if (s.includes(q)) return 0.55

    // subsequence ("ffx" -> "firefox"): tighter matches score higher
    let qi = 0, first = -1, last = -1
    for (let i = 0; i < s.length && qi < q.length; i++) {
        if (s[i] === q[qi]) {
            if (first < 0) first = i
            last = i
            qi++
        }
    }
    if (qi < q.length) return 0
    return 0.2 + 0.25 * (q.length / (last - first + 1))
}

function prepare(entries) {
    return entries.map(e => ({
        entry: e,
        name: (e.name ?? "").toLowerCase(),
        generic: (e.genericName ?? "").toLowerCase(),
        keywords: (e.keywords ?? []).join(" ").toLowerCase(),
    }))
}

function search(query, prepared, freq) {
    const q = query.trim().toLowerCase()
    const bonus = p => Math.min(0.15, Math.log1p(freq[p.entry.id] ?? 0) * 0.04)

    // empty query: most-used apps first
    if (!q) {
        return prepared
            .map(p => ({ entry: p.entry, score: freq[p.entry.id] ?? 0 }))
            .sort((a, b) => b.score - a.score)
            .map(r => r.entry)
    }

    const out = []
    for (const p of prepared) {
        const s = Math.max(
            scoreField(q, p.name) * W.name,
            scoreField(q, p.generic) * W.generic,
            scoreField(q, p.keywords) * W.keywords
        )
        if (s > 0.15) out.push({ entry: p.entry, score: s + bonus(p) })
    }

    return out
        .sort((a, b) => b.score - a.score)
        .map(r => r.entry)
}