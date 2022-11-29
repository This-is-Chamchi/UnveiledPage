using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Sirenix.OdinInspector;

public class UI_Boss_2Stage : MonoBehaviour
{
    [SerializeField]
    private Anna Anna;

    [SerializeField]
    private UIGaugeWithPointer hpGauge;
    [ReadOnly]
    private float currentAnnaHpAmount;
    [ReadOnly]
    private float targetAnnaHpAmount;


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
        targetAnnaHpAmount = Anna.Anna_CurrentHP / Anna.AnnaHP_Phase1;

        currentAnnaHpAmount = Mathf.Lerp(currentAnnaHpAmount, targetAnnaHpAmount, Time.deltaTime * dampingTime);


            hpGauge.UpdateGauge(currentAnnaHpAmount);
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
