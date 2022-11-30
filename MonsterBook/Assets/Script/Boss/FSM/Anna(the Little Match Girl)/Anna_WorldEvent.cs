using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Anna_WorldEvent : MonoBehaviour
{
    public GameObject FrozenScreen;
    private float time;
    [HideInInspector] public  bool GrannyAble;
    public float GrannyCoolTime;
    public float HumanMatchCoolTime;
    public GameObject Granny;
    public GameObject Granny1_SpawnPoint;
    public GameObject Granny2_SpawnPoint;


    public ParticleSystem Blizzard;
    public GameObject HumanMatch_Blizzard;
    public GameObject HumanMaych_Blizzard_SpawnPoint;
    public GameObject ComfortZone;
    private Renderer ComfortZoneRenderer;

    public GameObject[] HumanMatch_finish_SpawnPoint;

    public GameObject HumanMatch_finish_SpawnPoint0;
    public GameObject HumanMatch_finish_SpawnPoint1;
    public GameObject HumanMatch_finish_SpawnPoint2;
    public GameObject HumanMatch_finish_SpawnPoint3;
    public GameObject HumanMatch_finish_SpawnPoint4;



    public GameObject HumanMatch_finish;

    private GameObject Player;
    private bool LastMatchtrigger;
    private int MatchCount;
    

    public void LastMatch()
    {
        LastMatchtrigger = true;
    }

    public void CreateGranny()
    {
        Instantiate(Granny, Granny1_SpawnPoint.transform.position, new Quaternion(0, 0, 0, 0));
        Instantiate(Granny, Granny2_SpawnPoint.transform.position,new Quaternion(0,0,0,0));
        FrozenScreen.GetComponent<FlozenScreen>().Phasetwo = true;
    }

    public void BlizzardStart()
    {
        FrozenScreen.GetComponent<FlozenScreen>().FlozenStart = true;
        Instantiate(HumanMatch_Blizzard, HumanMaych_Blizzard_SpawnPoint.transform.position, new Quaternion(0, 180, 180, 0));
        Instantiate(ComfortZone, HumanMaych_Blizzard_SpawnPoint.transform.position, new Quaternion(0, 180, 180, 0));
        ComfortZone.GetComponent<ParticleSystem>().Play();
        ComfortZoneRenderer.sharedMaterial.SetFloat("_Dissolve_Value", -1);
        Blizzard.Play();  //눈보라 실행

    }

    public void BlizzardEnd()
    {

        FrozenScreen.GetComponent<FlozenScreen>().Clear(true);
        Blizzard.Stop();  //눈보라 실행
    }
    void Start()
    {
        ComfortZoneRenderer = ComfortZone.GetComponent<Renderer>();
        FrozenScreen = GameObject.FindWithTag("FrozenScreen");
        Player = GameObject.FindWithTag("Player");
        LastMatchtrigger = false;
        GrannyAble = false;
        MatchCount = 0;
    }


    void Update()
    {
        if (GrannyAble == true)
        {
            time += Time.deltaTime;
            if(time > GrannyCoolTime+10f)   //할머니 지속시간 10초
            {
                BlizzardEnd();
                CreateGranny();
                Debug.Log("할머니소환쿨");
                FrozenScreen.GetComponent<FlozenScreen>().Phasetwo = true;
                time = 0f;
            }
        }

        if(LastMatchtrigger == true)
        {
            time += Time.deltaTime;
            if( time > 1.0f )
            {
                if(MatchCount == 0)
                {
                    Instantiate(HumanMatch_finish, HumanMatch_finish_SpawnPoint0.transform);
                }
                else if (MatchCount == 1)
                {
                    Instantiate(HumanMatch_finish, HumanMatch_finish_SpawnPoint1.transform);
                }
                else if (MatchCount == 2)
                {
                    Instantiate(HumanMatch_finish, HumanMatch_finish_SpawnPoint2.transform);
                }
                else if (MatchCount == 3)
                {
                    Instantiate(HumanMatch_finish, HumanMatch_finish_SpawnPoint3.transform);
                }
                else if (MatchCount == 4)
                {
                    Instantiate(HumanMatch_finish, HumanMatch_finish_SpawnPoint4.transform);
                }

                //Instantiate(HumanMatch_finish, HumanMatch_finish_SpawnPoint[MatchCount].transform);
                time = 0;
                MatchCount++;
                if(MatchCount == 5)
                {
                    LastMatchtrigger = false;
                }

                if(MatchCount > 6 || MatchCount < -1)
                {
                    Debug.LogError(MatchCount + " : MatchCount");
                }

            }

        }


    }


}
