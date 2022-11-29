using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using Sirenix.OdinInspector;

public class ObjectTweenShearShaker : MonoBehaviour
{
    public enum CycleType
    {
        Unset,
        Sin,
        Cos,
    }


    private MeshRenderer meshRenderer;
    private MaterialPropertyBlock materialProperty;

    [SerializeField]
    protected CycleType cycleType;

    [SerializeField]
    private float cycleOffset;
    [SerializeField]
    [Range(0.01f, 10f)]
    private float cyclePeriod = 0.01f;

    [SerializeField]
    private float amountMultiply = 1f;

    [SerializeField]
    protected AnimationCurve animationCurve;

    [SerializeField]
    private bool autoActiveByPlay = false;
    [SerializeField]
    private bool autoStartPlay = false;

    [SerializeField]
    private float animationTime;

    [SerializeField]
    private UnityEvent completeEvent;

    [SerializeField]
    private UnityEvent stopEvent;

    private Coroutine animatoinCoroutine;

    private void Awake()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        materialProperty = new MaterialPropertyBlock();
    }

    private void Start()
    {
        if (autoStartPlay)
            PlayAnimation();
    }

    [Button("Àç»ý")]
    public void PlayAnimation()
    {
        if (autoActiveByPlay)
            gameObject.SetActive(true);

        if (animatoinCoroutine != null)
        {
            StopCoroutine(animatoinCoroutine);
        }

        animatoinCoroutine = StartCoroutine(CoShakeAnimate());
    }

    public void Stop()
    {
        if (animatoinCoroutine != null)
        {
            StopCoroutine(animatoinCoroutine);
        }

        stopEvent?.Invoke();
    }
    IEnumerator CoShakeAnimate()
    {
        var currentTime = 0f;

        while (true)
        {
            currentTime += Time.deltaTime;
            var lerpTime = currentTime / animationTime;

            var lerpValue = 0f;

            switch (cycleType)
            {
                case CycleType.Unset:
                    lerpValue = animationCurve.Evaluate(lerpTime);
                    break;
                case CycleType.Sin:
                    lerpValue = Mathf.Sin(lerpTime * cyclePeriod + cycleOffset);
                    break;
                case CycleType.Cos:
                    lerpValue = Mathf.Cos(lerpTime * cyclePeriod + cycleOffset);
                    break;
            }


            materialProperty.SetFloat("_Shear", lerpValue * amountMultiply);
            meshRenderer.SetPropertyBlock(materialProperty);

            if (lerpTime > 1f)
            {
                break;
            }

            completeEvent?.Invoke();
            yield return null;
        }
    }
}
