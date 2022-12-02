using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Sirenix.OdinInspector;

public class UIBossStick : MonoBehaviour
{
    [SerializeField]
    private UIBaseImage faceImage;

    [SerializeField]
    private RectTransform faceRectTransform;

    [SerializeField]
    private Sprite normalFace;

    [SerializeField]
    private Sprite hitFace;

    [SerializeField]
    private float spinAnimationTime;

    [SerializeField]
    private AnimationCurve spinAnimatoinCurve;

    [SerializeField]
    private float stayAnimationTime;

    [SerializeField]
    bool isFlip = false;

    Coroutine faceChangeAnimation;

    [Button("Play")]
    public void PlayChangeAnimation()
    {
        if (faceChangeAnimation != null)
        {
            StopCoroutine(faceChangeAnimation);
        }
        faceChangeAnimation = StartCoroutine(CoChangeAnimation());
    }

    public void ChangeFace(bool isHit)
    {
        faceImage.SetImage(isHit ? hitFace : normalFace);
    }

    IEnumerator CoChangeAnimation()
    {
        var time = 0f;
        var lerpTime = 0f;

        ChangeFace(false);
        while (lerpTime < 1f)
        {
            time += Time.deltaTime;
            lerpTime = time / spinAnimationTime;

            faceRectTransform.localRotation = Quaternion.Euler(0, 180f * spinAnimatoinCurve.Evaluate(lerpTime), 0);
            if (!isFlip && lerpTime > 0.5f)
            {
                isFlip = true;
                ChangeFace(true);
            }
            yield return null;
        }

        time = 0f;
        lerpTime = 0f;
        while (lerpTime < 1f)
        {
            time += Time.deltaTime;
            lerpTime = time / stayAnimationTime;
            yield return null;
        }

 

        time = 0f;
        lerpTime = 0f;
        while (lerpTime < 1f)
        {
            time += Time.deltaTime;
            lerpTime = time / spinAnimationTime;
            faceRectTransform.localRotation = Quaternion.Euler(0, 180f + 180f * spinAnimatoinCurve.Evaluate(lerpTime), 0);
    
            if (isFlip && lerpTime > 0.5f)
            {
                isFlip = false;
                ChangeFace(false);
            }
            yield return null;
        }

    }


}
