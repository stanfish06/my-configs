// Cursor trail of vertical stripes that fade toward the tail.
// Shares the SDF/parallelogram scaffolding with cursor_blaze_tapered.glsl.

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);
    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);
    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}

float determineStartVertexFactor(vec2 c, vec2 p) {
    float condition1 = step(p.x, c.x) * step(c.y, p.y);
    float condition2 = step(c.x, p.x) * step(p.y, c.y);
    return 1.0 - max(condition1, condition2);
}

float isLess(float c, float p) {
    return 1.0 - step(p, c);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

float ease(float x) {
    return pow(1.0 - x, 3.0);
}

const vec4  TRAIL_COLOR        = vec4(0.7, 0.4, 1.0, 1.0);
const vec4  TRAIL_COLOR_ACCENT = vec4(0.7, 0.4, 1.0, 1.0);
const float DURATION           = 0.35;   // seconds
const float LINE_COUNT         = 100.0;   // vertical stripes per unit of normalized x

// Bloom settings. Set BLOOM_STRENGTH to 0.0 to disable entirely; the outer
// bloom.glsl pass (if still chained in your ghostty config) is independent of
// this and will continue to bloom everything uniformly.
const float BLOOM_STRENGTH     = 1.0;    // overall bloom intensity (try 0.5 - 2.0)
const float BLOOM_RADIUS       = 1.5;    // sample offset in pixels

// Golden spiral bloom samples from bloom.glsl (qwerasd205). xy = offset, z = weight.
const vec3[24] BLOOM_SAMPLES = {
  vec3( 0.1693761725038636,  0.9855514761735895,  1.0),
  vec3(-1.333070830962943,   0.4721463328627773,  0.7071067811865475),
  vec3(-0.8464394909806497, -1.51113870578065,    0.5773502691896258),
  vec3( 1.554155680728463,  -1.2588090085709776,  0.5),
  vec3( 1.681364377589461,   1.4741145918052656,  0.4472135954999579),
  vec3(-1.2795157692199817,  2.088741103228784,   0.4082482904638631),
  vec3(-2.4575847530631187, -0.9799373355024756,  0.3779644730092272),
  vec3( 0.5874641440200847, -2.7667464429345077,  0.35355339059327373),
  vec3( 2.997715703369726,   0.11704939884745152, 0.3333333333333333),
  vec3( 0.41360842451688395, 3.1351121305574803,  0.31622776601683794),
  vec3(-3.167149933769243,   0.9844599011770256,  0.30151134457776363),
  vec3(-1.5736713846521535, -3.0860263079123245,  0.2886751345948129),
  vec3( 2.888202648340422,  -2.1583061557896213,  0.2773500981126146),
  vec3( 2.7150778983300325,  2.5745586041105715,  0.2672612419124244),
  vec3(-2.1504069972377464,  3.2211410627650165,  0.2581988897471611),
  vec3(-3.6548858794907493, -1.6253643308191343,  0.25),
  vec3( 1.0130775986052671, -3.9967078676335834,  0.24253562503633297),
  vec3( 4.229723673607257,   0.33081361055181563, 0.23570226039551587),
  vec3( 0.40107790291173834, 4.340407413572593,   0.22941573387056174),
  vec3(-4.319124570236028,   1.159811599693438,   0.22360679774997896),
  vec3(-1.9209044802827355, -4.160543952132907,   0.2182178902359924),
  vec3( 3.8639122286635708, -2.6589814382925123,  0.21320071635561041),
  vec3( 3.3486228404946234,  3.4331800232609,     0.20851441405707477),
  vec3(-2.8769733643574344,  3.9652268864187157,  0.20412414523193154)
};

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    vec4 currentCursor  = vec4(normalize(iCurrentCursor.xy,  1.), normalize(iCurrentCursor.zw,  0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);

    float vertexFactor         = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
    float invertedVertexFactor = 1.0 - vertexFactor;
    float xFactor              = isLess(previousCursor.x, currentCursor.x);
    float yFactor              = isLess(currentCursor.y, previousCursor.y);

    vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor,         currentCursor.y - currentCursor.w);
    vec2 v1 = vec2(currentCursor.x + currentCursor.z * xFactor,              currentCursor.y - currentCursor.w * yFactor);
    vec2 v2 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
    vec2 v3 = centerCP;

    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    float sdfTrail         = getSdfParallelogram(vu, v0, v1, v2, v3);

    float progress      = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float easedProgress = ease(progress);
    float lineLength    = distance(centerCC, centerCP);

    // Project the pixel onto the trail axis: 0 at previous cursor, 1 at current cursor.
    vec2  trailDir  = centerCC - centerCP;
    float trailLen  = max(length(trailDir), 1e-5);
    vec2  trailDirN = trailDir / trailLen;
    float along     = clamp(dot(vu - centerCP, trailDirN) / trailLen, 0.0, 1.0);
    float spatialFade = pow(along, 1.4); // brighter near current cursor (higher value -> more decay)

    // Vertical stripe pattern.
    float stripeWave = abs(fract(vu.x * LINE_COUNT) - 0.5) * 2.0; // 0 at stripe centers, 1 at edges
    float stripe     = 1.0 - smoothstep(0.15, 0.38, stripeWave);

    float inTrail = antialising(sdfTrail);

    // Compose trail color.
    vec4 newColor = mix(fragColor, TRAIL_COLOR, stripe * inTrail * spatialFade);
    // A little accent on the brightest stripes near the cursor.
    newColor = mix(newColor, TRAIL_COLOR_ACCENT, stripe * inTrail * pow(spatialFade, 3.0) * 0.8);

    // Draw current cursor block.
    newColor = mix(newColor, TRAIL_COLOR, antialising(sdfCurrentCursor));
    newColor = mix(newColor, fragColor, step(sdfCurrentCursor, 0.));

    // Retract animation: reveal newColor only within easedProgress*lineLength of the cursor.
    fragColor = mix(fragColor, newColor, step(sdfCurrentCursor, easedProgress * lineLength));

    // Bloom pass: instead of re-sampling iChannel0 (which is the raw terminal,
    // not our trail), we re-evaluate the stripe+trail alpha at 24 golden-spiral
    // offsets and accumulate a glow. This produces bloom localized to the trail
    // itself even when this shader runs without bloom.glsl chained after it.
    if (BLOOM_STRENGTH > 0.0) {
        float bloomStep  = BLOOM_RADIUS * 2.0 / iResolution.y;
        vec2  cursorPivot = currentCursor.xy - (currentCursor.zw * offsetFactor);
        vec2  cursorHalf  = currentCursor.zw * 0.5;
        vec3  bloomAccum  = vec3(0.0);
        for (int i = 0; i < 24; i++) {
            vec3 s = BLOOM_SAMPLES[i];
            vec2 probe = vu + s.xy * bloomStep;

            // Re-evaluate the stripe trail alpha at the probe position.
            float probeWave    = abs(fract(probe.x * LINE_COUNT) - 0.5) * 2.0;
            float probeStripe  = 1.0 - smoothstep(0.15, 0.38, probeWave);
            float probeSdfTr   = getSdfParallelogram(probe, v0, v1, v2, v3);
            float probeInTrail = 1.0 - step(0.0, probeSdfTr);
            float probeAlong   = clamp(dot(probe - centerCP, trailDirN) / trailLen, 0.0, 1.0);
            float probeFade    = pow(probeAlong, 1.4);
            float probeTrailA  = probeStripe * probeInTrail * probeFade;

            // Re-evaluate the cursor fill too so its edge blooms as well.
            float probeSdfCur = getSdfRectangle(probe, cursorPivot, cursorHalf);
            float probeCursor = 1.0 - step(0.0, probeSdfCur);

            // Apply the same retract mask so bloom retracts with the trail.
            float probeRetract = step(probeSdfCur, easedProgress * lineLength);
            probeTrailA *= probeRetract;

            vec3 probeColor = mix(TRAIL_COLOR.rgb, TRAIL_COLOR_ACCENT.rgb, probeFade * 0.7);
            bloomAccum += probeColor * probeTrailA * s.z;
            bloomAccum += TRAIL_COLOR.rgb * probeCursor * s.z * 0.6;
        }
        fragColor.rgb += bloomAccum * BLOOM_STRENGTH * 0.08;
    }
}
