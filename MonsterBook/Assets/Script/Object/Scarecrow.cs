using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Scarecrow : MonoBehaviour, IEntity, ICutOff
{
    [SerializeField] private int curHp;
    private bool cut;

    [SerializeField] private GameObject frag;

    public void OnDamage(int damage, Vector3 pos)
    {
        curHp -= damage;
        if (curHp == 0)
        {
            cut = true;
        }
    }

    public void OnRecovery(int heal)
    {

    }

    public bool CheckCutOff()
    {
        return curHp == 0 ? true : false;
    }

    public void CutDamage()
    {
        frag.SetActive(true);
        gameObject.SetActive(false);
    }

}
