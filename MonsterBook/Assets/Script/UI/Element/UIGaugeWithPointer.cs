using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIGaugeWithPointer : UIBaseGauge
{
    [SerializeField]
    private RectTransform fillArea;
    [SerializeField]
    private RectTransform pointer;

    public override void UpdateGauge(float progress)
    {
        base.UpdateGauge(progress);
        pointer.anchoredPosition = Vector2.right * fillArea.rect.width * progress;
    }

    public void ChangePointer(RectTransform newPointer)
    {
        pointer = newPointer;
    }

}
