using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Sirenix.OdinInspector;

public class UI_Boss_1Stage : MonoBehaviour
{
    [SerializeField]
    private Hansel hansel;

    [SerializeField]
    private UIGaugeWithPointer hpGauge;
    [ReadOnly]
    private float currentHanselHpAmount;
    [ReadOnly]
    private float targetHanselHpAmount;

    [SerializeField]
    private Gretel gratel;

    [ReadOnly]
    private float currentGratelHpAmount;
    [ReadOnly]
    private float targetGratelHpAmount;

    public float dampingTime = 2f;

    [SerializeField]
    private RectTransform[] bossSticks;

    [SerializeField]
    private UITweenAnimator[] bossStickVisibleAnimations;

    [SerializeField]
    private UITweenAnimator[] bossStickInVisibleAnimations;

    public bool isGratelPhase = false;

    void Update()
    {
        //몬스터 체력 가져오는 법
        targetHanselHpAmount = hansel.CurrentHP / hansel.HanselHP;
        targetGratelHpAmount = gratel.CurrentHP / gratel.GretelHP;

        currentHanselHpAmount = Mathf.Lerp(currentHanselHpAmount, targetHanselHpAmount, Time.deltaTime * dampingTime);
        currentGratelHpAmount = Mathf.Lerp(currentGratelHpAmount, targetGratelHpAmount, Time.deltaTime * dampingTime);

        if (isGratelPhase)
        {
            hpGauge.UpdateGauge(currentGratelHpAmount);
        }
        else
        {
            hpGauge.UpdateGauge(currentHanselHpAmount);
        }
    }

    [Button("페이즈 체인지")]
    public void ChangePhase(bool isGratelPhase)
    {
        this.isGratelPhase = isGratelPhase;
        hpGauge.ChangePointer(isGratelPhase ? bossSticks[1] : bossSticks[0]);

        if (isGratelPhase)
        {
            bossStickInVisibleAnimations[0].PlayAnimation();
            bossStickVisibleAnimations[1].PlayAnimation();
        }
        else
        {
            bossStickVisibleAnimations[0].PlayAnimation();
            bossStickInVisibleAnimations[1].PlayAnimation();
        }
    }

    public void HitAnimation()
    {
        var stick = isGratelPhase ? bossSticks[1] : bossSticks[0];
        stick.GetComponent<UIBossStick>().PlayChangeAnimation();
    }


}
