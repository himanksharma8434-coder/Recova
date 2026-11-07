# Body Engine Science & Methodology Reference

**Algorithm Version:** `2.0.0`  
**Classification:** General Health & Wellness / Athletic Performance (Non-Diagnostic)  
**Storage Architecture:** 100% Offline-First Local Drift (SQLite)  

---

## 1. Executive Summary & Design Philosophy

Unlike commercial closed-ecosystem platforms (e.g. WHOOP, Garmin Firstbeat) which guard their physiological algorithms as proprietary trade secrets, this engine is built on **100% transparent, published sports-science and cardiovascular physiology literature**.

### Core Tenets of the Engine:
1. **No Fabricated Precision:** When a sensor does not report a metric (e.g., raw beat-to-beat RR intervals or deep/REM sleep hypnograms), the app calculates transparent physiological approximations derived from available telemetry, explicitly tags them with `calculationMethod: 'estimated'` and `source: 'estimated'`, and lowers the confidence score. Fake numbers are never presented as measured telemetry.
2. **Personal Baselines Over Population Averages:** Heart rate variability (HRV), resting heart rate (RHR), and sleep architecture vary drastically across genetics, age, and biological sex. Population percentiles are only used as cold-start fallbacks; all daily evaluations are computed against the user's personal 7-day rolling average and 60-day baseline normal range band ($\text{Mean} \pm 0.75 \times \text{SD}$).
3. **Reproducibility Through Versioning:** Every row written to local SQLite stores the `algorithmVersion` (`2.0.0`). When formulas or weights are tuned, historical data retains its original calculation version.
4. **Wellness-First Compliance:** The engine strictly complies with the FDA 2026 General Wellness Guidance. It provides athletic training readiness, recovery insights, and lifestyle correlations; it never diagnoses medical conditions, detects arrhythmias, or claims clinical equivalence.

---

## 2. Physiological Pillars & Mathematical Formulations

```
                              ┌────────────────────────────────────────┐
                              │           OVERNIGHT TELEMETRY          │
                              └───────────────────┬────────────────────┘
                                                  │
            ┌─────────────────────┬───────────────┴───────────────┬─────────────────────┐
            ▼                     ▼                               ▼                     ▼
┌───────────────────────┐ ┌──────────────┐             ┌─────────────────────┐ ┌─────────────────┐
│     HRV (RMSSD)       │ │ Resting HR   │             │  Sleep Architecture │ │ Respiratory Rate│
│  - Clean RR Interval  │ │ - 5-min      │             │  - Dynamic Need     │ │ - Nocturnal     │
│  - ln(RMSSD) Transform│ │   nadir      │             │  - 4-Pillar Score   │ │   breaths/min   │
│  - 60d Normal Band    │ │ - 60d Base   │             │  - Restorative %    │ │ - Personal Base │
└───────────┬───────────┘ └──────┬───────┘             └──────────┬──────────┘ └────────┬────────┘
            │                    │                                │                     │
            ▼                    ▼                                ▼                     ▼
        HRV Z-Score         RHR Inverted Z                  Sleep Z-Score         Resp Inverted Z
        (Weight 50%)        (Weight 20%)                    (Weight 20%)          (Weight 10%)
            │                    │                                │                     │
            └────────────────────┼────────────────────────────────┴─────────────────────┘
                                 │
                                 ▼
                     Composite Normalized Z-Score
                                 │
                                 ▼
                     Logistic Sigmoid Mapping
                     Readiness = 100 / (1 + e^(-1.1 * Z))
                                 │
                                 ▼
                     ┌───────────────────────┐
                     │ Sleep Deficit Governor│ (If sleep < 6h, score capped <= 66)
                     └───────────┬───────────┘
                                 │
                                 ▼
                      MORNING READINESS SCORE
                           (0 to 100%)
```

---

## 3. Pillar 1: Heart Rate Variability (HRV Engine)

### 3.1. What It Measures
Heart Rate Variability (HRV) measures the millisecond beat-to-beat fluctuations between consecutive heartbeats (R-waves). It reflects the dynamic push-pull between the **sympathetic nervous system** (fight-or-flight, activation, stress) and the **parasympathetic nervous system** (rest-and-digest, cellular repair, vagal tone).

Higher parasympathetic activity increases beat-to-beat variability (higher RMSSD). Suppressed variability signals systemic fatigue, acute alcohol intake, dehydration, overtraining, or impending infection.

### 3.2. Data Cleaning & Ectopic Beat Rejection
Raw RR intervals captured by sensors are susceptible to premature ventricular contractions (PVCs) and optical motion artifacts.
1. **Range Filtering:** Intervals outside $[300\text{ ms}, 2000\text{ ms}]$ ($30\text{--}200\text{ bpm}$) are discarded.
2. **Successive Percentage Difference Filtering:** Any RR interval that deviates by more than $20\%$ from the preceding valid beat is rejected as an ectopic beat or movement artifact:
   $$\frac{|RR_{i} - RR_{i-1}|}{RR_{i-1}} \le 0.20$$

### 3.3. RMSSD Calculation
Root Mean Square of Successive Differences (RMSSD) is the gold standard time-domain metric reflecting short-term vagally-mediated autonomic modulation (Shaffer & Ginsberg, 2017):
$$\text{RMSSD} = \sqrt{\frac{1}{N - 1} \sum_{i=1}^{N - 1} (RR_{i+1} - RR_i)^2}$$

### 3.4. Log-Transformation: $\ln(\text{RMSSD})$
Raw RMSSD is strongly right-skewed across human populations. To enable valid parametric Gaussian statistics (Z-scores, standard deviations, confidence intervals), the engine transforms RMSSD into natural-log space:
$$x = \ln(\text{RMSSD})$$

### 3.5. 7-Day Rolling Baseline & 60-Day Normal Range Band
Following athletic sports-cardiology best practices (Plews et al., 2013; Buchheit, 2014):
- **7-Day Rolling Mean:** $\mu_7 = \frac{1}{7} \sum_{k=1}^7 x_k$ (requires $\ge 3$ valid nights).
- **7-Day Coefficient of Variation (CV):** $CV_7 = \frac{\sigma_7}{\mu_7}$. A rising CV indicates autonomic instability; a low, stable CV indicates adaptation to training.
- **60-Day Personal Normal Range Band:** Built from 30 to 60 historical nights:
  $$\text{Normal Band} = \left[ \mu_{60} - 0.75 \times \sigma_{60}, \;\; \mu_{60} + 0.75 \times \sigma_{60} \right]$$
- **Standardized Z-Score:** Clamped to $[-3.0, +3.0]$:
  $$Z_{\text{HRV}} = \text{clamp}\left(\frac{x_{\text{today}} - \mu_{60}}{\sigma_{60}}, \;-3.0, \;+3.0\right)$$

### 3.6. Autonomic Trend Classification
| Status | Condition | Physiological Interpretation |
|---|---|---|
| **Calibrating** | History $< 14$ days | Baseline accumulating; normal band not yet stable. |
| **Stable** | $x_{\text{today}} \in \text{Normal Band}$ and $\mu_7 \in \text{Normal Band}$ | Parasympathetic equilibrium. Body adapting well to load. |
| **Acute Suppression** | $x_{\text{today}} < \text{Lower Bound}$, $\mu_7$ inside band | Single-night dip (e.g. alcohol, late heavy meal, intense training, acute mental stress). |
| **Acute Elevation** | $x_{\text{today}} > \text{Upper Bound}$, $\mu_7$ inside band | Single-night parasympathetic spike. High recovery state. |
| **Sustained Suppression** | $\mu_7 < \text{Lower Bound}$ | Multi-day autonomic depression. Strong signal of overtraining, chronic fatigue, or impending illness. Prioritize rest. |
| **Sustained Elevation** | $\mu_7 > \text{Upper Bound}$ | Parasympathetic supercompensation (often seen during taper weeks before competition). |

### 3.7. Fallback: Nocturnal PPG Pulse Interval Estimation
When a wearable reports 1-to-5 minute pulse rate samples instead of raw millisecond RR intervals, the engine estimates RMSSD from successive inter-sample heart-rate differences during slow-wave nocturnal rest:
$$\text{IBI}_i = \frac{60000}{\text{BPM}_i}, \quad \Delta \text{IBI} = |\text{IBI}_{i+1} - \text{IBI}_i|$$
A calibration factor ($0.72$) is applied to compensate for minute-scale respiratory sinus arrhythmia dampening. The metric is explicitly tagged as `HrvSource.estimated`, and readiness confidence is capped at `medium`.

---

## 4. Pillar 2: Resting Heart Rate (RHR Engine)

### 4.1. What It Measures
Resting Heart Rate (RHR) measures basal cardiovascular efficiency. Elevated nocturnal RHR reflects elevated sympathetic cardiac drive, cardiac fatigue, dehydration, fever, or alcohol metabolism.

### 4.2. 5-Minute Nadir Extraction
Rather than averaging the entire night (which includes tossing, turning, and light sleep awakenings), the engine scans the sleep window using a 5-minute sliding window to identify the **sustained circadian nadir**:
$$\text{RHR}_{\text{nadir}} = \min_{t} \left( \frac{1}{|W_t|} \sum_{s \in W_t} \text{BPM}_s \right), \quad W_t = [t, \; t + 5\text{ min}], \; |W_t| \ge 3$$

### 4.3. Inverted Z-Score
Unlike HRV (where higher is better), lower RHR indicates superior recovery. Therefore, the Z-score is inverted:
$$Z_{\text{RHR}} = \text{clamp}\left(\frac{\mu_{60} - \text{RHR}_{\text{today}}}{\sigma_{60}}, \;-3.0, \;+3.0\right)$$

---

## 5. Pillar 3: Sleep Architecture & Dynamic Sleep Need

### 5.1. Dynamic Sleep Need Formula
Tonight's sleep target is not a rigid 8 hours; it adjusts dynamically to daily strain, sleep debt, and naps:
$$\text{Sleep Need} = \text{clamp}\left(\text{Base Need} + \text{Strain Addition} + \text{Debt Payback} - \text{Nap Credit}, \; 420\text{ min}, \; 600\text{ min}\right)$$

1. **Base Need:** Individual baseline (default: 480 min / 8.0 hrs).
2. **Strain Addition:** Cardiovascular strain beyond moderate (10.0) requires cellular and muscle repair:
   $$\text{Strain Addition} = \max(0, \; (\text{Strain} - 10.0) \times 2.5\text{ min})$$
3. **Debt Payback:** 20% of accumulated sleep debt is amortized per night (capped at 90 min to prevent sleep inertia):
   $$\text{Debt Addition} = \min(90\text{ min}, \; 0.20 \times \text{Debt}_{\text{accumulated}})$$
4. **Nap Credit:** Verified daytime sleep is credited 1:1 against tonight's need.

### 5.2. Multi-Pillar Sleep Score (0 to 100)
$$\text{Sleep Score} = 0.40 \times S_{\text{sufficiency}} + 0.25 \times S_{\text{efficiency}} + 0.20 \times S_{\text{restorative}} + 0.15 \times S_{\text{consistency}}$$

1. **Sufficiency ($40\%$):** Time asleep divided by personalized Sleep Need.
2. **Efficiency ($25\%$):** $\frac{\text{Time Asleep}}{\text{Time in Bed}} \times 100$. Optimal $\ge 85\%$.
3. **Restorative Share ($20\%$):** Proportion of sleep spent in Deep (Slow-Wave) and REM sleep:
   $$\text{Restorative Share} = \frac{\text{Deep Minutes} + \text{REM Minutes}}{\text{Total Asleep Minutes}} \times 100 \quad (\text{Target: } 35\%\text{--}45\%)$$
4. **Consistency ($15\%$):** Standard deviation of bedtimes over the past 7 nights:
   - $< 30$ min variance = 100%
   - $> 120$ min variance = drops to 30%

### 5.3. Transparent Fallback for Missing Sleep Stages
If the wearable reports only total sleep duration without hypnogram stages (e.g., standard Health Connect import), the engine estimates restorative share from sleep efficiency, tags `stageProvenance: SleepStageProvenance.estimated`, and notes this clearly in the sleep breakdown.

---

## 6. Pillar 4: Cardiovascular Load / Daily Strain (0 to 21 Scale)

### 6.1. Karvonen Heart Rate Reserve (HRR)
Intensity is normalized to the user's personal cardiovascular range:
$$\text{HRR Intensity} = \frac{\text{HR} - \text{RHR}}{\text{MaxHR} - \text{RHR}}$$

Five standard zones are derived:
- **Zone 1 (50%–60% HRR):** Active recovery
- **Zone 2 (60%–70% HRR):** Aerobic base / fat oxidation
- **Zone 3 (70%–80% HRR):** Aerobic endurance / tempo
- **Zone 4 (80%–90% HRR):** Anaerobic threshold
- **Zone 5 (90%–100% HRR):** Peak neuromuscular

### 6.2. Banister / Edwards Training Impulse (TRIMP)
$$\text{TRIMP} = \sum_{z=1}^5 (\text{Duration in Zone } z \times z \times 0.2)$$

### 6.3. Diminishing-Returns Logarithmic Display Scale (0 to 21)
Because physiological fatigue accumulates non-linearly (it is much harder to go from strain 14 to 18 than from 0 to 4), TRIMP is mapped to a diminishing-returns 0–21 scale with a scaling constant $S = 18.0$:
$$\text{Load Score} = 21 \times \left(1 - e^{-\frac{\text{TRIMP}}{18.0}}\right)$$

### 6.4. Morning Readiness-Driven Load Targets
- **Optimal Readiness ($\ge 67\%$):** Target load $14.0\text{--}18.0$ (push fitness).
- **Balanced Readiness ($34\%\text{--}66\%$):** Target load $10.0\text{--}13.9$ (maintain fitness).
- **Recovery Priority ($< 34\%$):** Target load $6.0\text{--}9.9$ (active recovery / restorative movement).

---

## 7. Composite Morning Readiness Engine

### 7.1. Dynamic Weight Normalization
When all metrics are present:
$$\text{Weights}: \quad W_{\text{HRV}} = 0.50, \quad W_{\text{RHR}} = 0.20, \quad W_{\text{Sleep}} = 0.20, \quad W_{\text{Resp}} = 0.10$$

If any metric is missing, active weights are re-normalized strictly to sum to $1.0$:
$$W_{\text{norm}, i} = \frac{W_i}{\sum_{k \in \text{Available}} W_k}, \quad Z_{\text{composite}} = \sum_{i \in \text{Available}} W_{\text{norm}, i} \times Z_i$$

### 7.2. Logistic Sigmoid Mapping
Composite Z is mapped to a natural 0–100 score via a logistic sigmoid with slope factor $k = 1.1$:
$$\text{Raw Readiness} = \frac{100}{1 + e^{-1.1 \times Z_{\text{composite}}}}$$

### 7.3. Sleep Deficit Governor (Safety & Realism Rule)
Even if an athlete exhibits elevated HRV, **insufficient sleep impairs cognitive reaction time, motor control, and immune function**. 
If total sleep duration is under 6.0 hours ($360\text{ min}$), the readiness score is strictly capped at a ceiling $\le 66.0$, preventing the user from receiving an "Optimal" readiness recommendation:
$$\text{Ceiling} = \text{clamp}\left(45.0 + \frac{\text{Sleep Minutes} - 240}{120} \times 21.0, \; 30.0, \; 66.0\right)$$

### 7.4. Calibration Timeline
| Days of History | Engine State | Score Displayed | Confidence |
|---|---|---|---|
| **Days 1–3** | Baseline Collection | `null` | `calibrating` (User shown collection progress) |
| **Days 4–13** | Provisional Calibration | Calculated score | `calibrating` (Provisional badge displayed) |
| **Day 14+** | Full Operational Baseline | Calculated score | `high` (or `medium` if HRV is estimated) |
| **Day 30+** | Stable Normal Range Band | Full 60-day band | `high` |

---

## 8. Intraday Stress & Energy Reserve

### 8.1. Daytime Stress (0 to 100)
Calculated from short-window resting heart rate elevation and HRV suppression during **sedentary, non-exercise periods**:
- During active workouts, stress scoring is paused (exertion is not autonomic stress).
- 4 Bands: **Calm** (0–25), **Balanced** (26–50), **Elevated** (51–75), **High** (76–100).

### 8.2. Energy Reserve
- Calibrates after 10 days of wear.
- Starts each morning aligned with the Morning Readiness Score and Sleep Quality.
- Drains throughout the day with workout load ($-3.5\text{ pts}$ per strain point) and prolonged daytime stress.
- Charges during verified restful sedentary periods ($+1.5\%$/hr) and daytime naps.

---

## 9. Athlete Training Readiness & Workload Balance (ACWR)

Following the work of Tim Gabbett (*The training-injury prevention paradox: should athletes be training smarter and harder?*, Br J Sports Med, 2016):
- **Acute Workload (7 Days):** $\text{Mean daily load over past 7 days}$.
- **Chronic Workload (28 Days):** $\text{Mean daily load over past 28 days}$.
- **Acute:Chronic Workload Ratio (ACWR):**
  $$\text{ACWR} = \frac{\text{Acute Workload}}{\text{Chronic Workload}}$$
- **Sweet Spot ($0.8 \le \text{ACWR} \le 1.3$):** Progressive fitness building with minimal injury risk.
- **Danger Zone ($\text{ACWR} > 1.4$):** Acute load spike relative to chronic physical preparation. Even if morning readiness is high, training guidance warns the athlete to cap volume to prevent soft-tissue injury.

---

## 10. Sensor Limitations & Technical Considerations

1. **Wrist Optical PPG vs. Chest Strap ECG:**
   - Optical PPG measures pulse volume waves at the microvascular bed, which introduces minor transit time jitter compared to electrical cardiac depolarization (ECG R-wave).
   - Motion, cold extremities, loose watch straps, and tattoos can degrade PPG signal-to-noise ratio.
   - For high-precision HRV benchmarking, an ECG chest strap (e.g., Polar H10) remains the gold standard.
2. **Slow-Wave Sleep (SWS) Timing:**
   - Autonomic tone is cleanest during deep non-REM (SWS) sleep, when mental arousal and dream-related sympathetic surges (REM) are absent. When stage breakdown is available, nocturnal RMSSD is sampled during SWS windows.
3. **Day-Boundary & Timezone Shifts:**
   - Sleep sessions spanning midnight or crossing time zones are tagged with explicit UTC timestamps and `timeZoneOffsetMinutes`. A day's nocturnal recovery is assigned to the waking date, ensuring night shifts and international travel do not duplicate or corrupt rolling 7-day baselines.

---

## 11. Scientific References & Literature Citations

1. **Plews, D. J., Laursen, P. B., Stanley, J., Kilding, A. E., & Buchheit, M. (2013).** Training adaptation and heart rate variability in elite endurance athletes: opening the door to effective monitoring. *Sports Medicine*, 43(9), 773-781.
2. **Buchheit, M. (2014).** Monitoring training status with HR measures: do all roads lead to Rome? *Frontiers in Physiology*, 5, 73.
3. **Shaffer, F., & Ginsberg, J. P. (2017).** An overview of heart rate variability metrics and norms. *Frontiers in Public Health*, 5, 258.
4. **Gabbett, T. J. (2016).** The training—injury prevention paradox: should athletes be training smarter and harder? *British Journal of Sports Medicine*, 50(5), 273-280.
5. **Banister, E. W. (1991).** Modeling elite athletic performance. *Physiological Testing of the High-Performance Athlete*, 2, 403-424.
6. **Karvonen, M. J., Kentala, E., & Mustala, O. (1957).** The effects of training on heart rate: a longitudinal study. *Annales Medicinae Experimentalis et Biologiae Fenniae*, 35(3), 307-315.
7. **FDA (January 2026).** *General Wellness: Policy for Low Risk Devices - Guidance for Industry and Food and Drug Administration Staff*. U.S. Department of Health and Human Services.

