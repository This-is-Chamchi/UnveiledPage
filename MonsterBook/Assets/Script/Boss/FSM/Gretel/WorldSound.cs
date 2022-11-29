using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldSound : MonoBehaviour
{
    public GameObject[] SoundObject;  //0 = ·¥ÇÁ 1 = ³¿ºñ 2 = ¸ð´ÚºÒ 3 = ¿ä¸®
    private int worldSoundID;


    // Start is called before the first frame update
    void Start()
    {


    }

    // Update is called once per frame
    void Update()
    {

    }

    public void WorldSoundPlay(string soundname,int num)
    {
        worldSoundID = SoundManager.PlayVFXLoopSound(soundname, SoundObject[num].transform);
    }

    public void WorldSoundStop(string soundname)
    {
        SoundManager.StopVFXLoopSound(worldSoundID);
    }





}
