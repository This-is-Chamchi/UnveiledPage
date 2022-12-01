using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Macaron_Die : MonoBehaviour
{
    private int hp;
    private GameObject Hansel;
    private GameObject Macaron;
    // Start is called before the first frame update
    void Start()
    {
        Macaron = GameObject.FindWithTag("BossBuff");
       hp = Macaron.GetComponent<Macaron>().gHP;
        Hansel = GameObject.FindWithTag("Boss");
    }

    // Update is called once per frame
    void Update()
    {
        if (hp == 0)
        {
            Macaron.GetComponent<Macaron>().CutDamage();
        }

        if(Hansel.GetComponent<Hansel>().CurrentHP == 0)
        {
            Destroy(Macaron);
        }

    }
}
