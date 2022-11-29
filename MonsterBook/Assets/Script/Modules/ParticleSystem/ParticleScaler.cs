using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleScaler : MonoBehaviour
{
    [SerializeField]
    private bool isAutoStart = true;

    public float animationTime;

    public AmountRangeFloat scaleRange;

    private ParticleSystemRenderer particleSystemRenderer;

    private Coroutine animationCoroutine;

    private void Awake()
    {
        particleSystemRenderer = GetComponent<ParticleSystemRenderer>();
    }

    private void OnEnable()
    {
        if (isAutoStart)
        {
            Play();
        }
    }

    public void Play()
    {
        if (animationCoroutine != null)
        {
            StopCoroutine(animationCoroutine);
        }

        animationCoroutine = StartCoroutine(CoScaleAnimation());
    }

    IEnumerator CoScaleAnimation()
    {
        var time = 0f;
        var lerpTime = time / animationTime;


        while (lerpTime < 1)
        {
            time += Time.deltaTime;
            lerpTime = time / animationTime;
            particleSystemRenderer.minParticleSize = Mathf.Lerp(scaleRange.min, scaleRange.max, lerpTime);
            particleSystemRenderer.maxParticleSize = Mathf.Lerp(scaleRange.min, scaleRange.max, lerpTime);
            yield return null;
        }

        particleSystemRenderer.minParticleSize = Mathf.Lerp(scaleRange.min, scaleRange.max, 1f);
        particleSystemRenderer.maxParticleSize = Mathf.Lerp(scaleRange.min, scaleRange.max, 1f);

        animationCoroutine = null;
    }


}
